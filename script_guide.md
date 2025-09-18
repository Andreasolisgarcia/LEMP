# Guide d'Installation WordPress avec LEMP Stack

## 📋 Commandes de Debug Utiles
```bash
# Logs Nginx
sudo cat /var/log/nginx/access.log
sudo cat /var/log/nginx/error.log

# Services système
sudo ls /usr/lib/systemd/system/ | grep nginx
sudo systemctl list-units --type=service | grep nginx

# Ports d'écoute
sudo netstat -tlnp
sudo ss -tlnp
sudo lsof -i
```

---

## 🌐 1. Installation et Configuration Nginx

### Installation
```bash
# Mise à jour du système
sudo apt update && sudo apt upgrade -y 

# Installation Nginx
sudo apt install nginx -y 

# Configuration des services
sudo systemctl enable nginx 
sudo systemctl start nginx 
sudo systemctl status nginx
```

### Vérification
```bash
# Vérifier les ports d'écoute
sudo netstat -tlnp
```

---

## 🐘 2. Installation et Configuration PHP

```bash
# Installation PHP 8.3 et extensions nécessaires
sudo apt install -y php php-fpm php-mysql php-mbstring php-bcmath php-zip php-gd php-curl php-xml

# Vérifier la version
php -v
```

### Configuration PHP
```bash
# Modifier le fichier de configuration
sudo vim /etc/php/8.3/fpm/php.ini
```

**Paramètres importants à modifier :**
- `upload_max_filesize = 128M` : taille max des fichiers uploadés
- `post_max_size = 128M` : taille max des données POST
- `memory_limit = 512M` : mémoire allouée à PHP
- `max_execution_time = 120` : temps max d'exécution
- `cgi.fix_pathinfo=0` : sécurité

---

## 🗄️ 3. Installation et Configuration MariaDB

### Installation
```bash
# Vérifier la version du système
lsb_release -a

# Installation MariaDB (méthode simple avec repo Ubuntu)
sudo apt update && sudo apt install -y mariadb-server mariadb-client

# Vérifier la version
mariadb --version

# Configuration des services
sudo systemctl start mariadb
sudo systemctl enable mariadb

# Sécurisation de l'installation
sudo mysql_secure_installation
```

### Configuration de la base de données
```bash
# Se connecter à MariaDB
sudo mariadb -u root -p
```

```sql
-- Créer la base de données
CREATE DATABASE wordpress_db;

-- Créer l'utilisateur avec droits limités
CREATE USER 'datascientestdbadmin'@'localhost' IDENTIFIED BY 'motdepasse';

-- Accorder les privilèges (SANS DROP DATABASE)
GRANT ALL PRIVILEGES ON wordpress_db.* TO 'datascientestdbadmin'@'localhost';

-- Vérifications
SHOW DATABASES;
SELECT User FROM mysql.user;
```

**💡 Note importante :** L'utilisateur ne peut PAS faire `DROP DATABASE` car les droits sont limités à `wordpress_db.*` et non `*.*` (droits globaux).

---

## 🌍 4. Installation et Configuration WordPress

### Téléchargement
```bash
# Aller dans le répertoire web
cd /var/www/html

# Télécharger WordPress
sudo wget https://wordpress.org/latest.tar.gz

# Extraire l'archive
sudo tar -zxvf latest.tar.gz

# Configuration du fichier de config
sudo mv /var/www/html/wordpress/wp-config-sample.php /var/www/html/wordpress/wp-config.php
sudo vim /var/www/html/wordpress/wp-config.php
```

### Permissions
```bash
# Définir les bonnes permissions
sudo chown -R www-data:www-data /var/www/html/wordpress
sudo chmod -R 755 /var/www/html/wordpress
```

### Configuration Nginx
```bash
# Créer le fichier de configuration du site
sudo vim /etc/nginx/conf.d/wordpress.conf

# Supprimer le site par défaut
sudo rm /etc/nginx/sites-enabled/default

# Tester la configuration
sudo nginx -t

# Recharger Nginx
sudo systemctl reload nginx
```

---

## 🔒 5. Configuration SSL avec Let's Encrypt

```bash
# Installation de Certbot
sudo apt-get install python3-certbot-nginx -y

# Génération du certificat SSL
sudo certbot --nginx -d wordpress.rea.ip-ddns.com
```

---

## 🧪 6. Tests et Vérifications

```bash
# Obtenir l'IP publique
curl ifconfig.me

# Vérifier la résolution DNS
nslookup wordpress.rea.ip-ddns.com

# Tester le site en local
curl -I http://localhost
curl -I -H "Host: wordpress.rea.ip-ddns.com" http://localhost

# Vérifier les services
sudo systemctl status nginx
sudo systemctl status php8.3-fpm
sudo systemctl status mariadb
```

---

## 💾 7. Plan de Sauvegarde

### Scripts de Sauvegarde

**Quotidien (02:00) - Base de données :**
```bash
#!/bin/bash
mysqldump -u datascientestdbadmin -p'motdepasse' wordpress_db > /home/ubuntu/backup/backup_db_$(date +%Y%m%d).sql
```

**Hebdomadaire (03:00 le lundi) - Dossier WordPress :**
```bash
#!/bin/bash
rsync -av --delete /var/www/html/wordpress/ /home/ubuntu/backup/wordpress/
```

**Mensuel (04:00 le 1er) - Configurations :**
```bash
#!/bin/bash
tar -czf /home/ubuntu/backup/backup_configs_$(date +%Y%m%d).tar.gz \
  /etc/nginx/conf.d/wordpress.conf \
  /etc/nginx/nginx.conf \
  /etc/php/8.3/fpm/php.ini \
  /etc/letsencrypt/
```

### Configuration Crontab
```bash
# Éditer le crontab
crontab -e

# Ajouter ces lignes :
0 2 * * * /home/ubuntu/db_backup.sh
0 3 * * 1 /home/ubuntu/wp_backup.sh
0 4 1 * * /home/ubuntu/config_backup.sh
```

### Rendre les scripts exécutables
```bash
chmod u+x /home/ubuntu/db_backup.sh
chmod u+x /home/ubuntu/wp_backup.sh
chmod u+x /home/ubuntu/config_backup.sh
```

---

## 📁 8. Livrables pour l'Examen

### Fichiers à inclure dans le ZIP :
- Configuration Nginx : `/etc/nginx/conf.d/wordpress.conf`
- Configuration principale Nginx : `/etc/nginx/nginx.conf`
- Configuration WordPress : `/var/www/html/wordpress/wp-config.php`
- Configuration PHP : `/etc/php/8.3/fpm/php.ini`
- Backup de la BDD : `backup_db_YYYYMMDD.sql`
- Logs Nginx : `/var/log/nginx/access.log` et `/var/log/nginx/error.log`
- Certificats SSL :
  - `/etc/letsencrypt/live/wordpress.rea.ip-ddns.com/fullchain.pem`
  - `/etc/letsencrypt/live/wordpress.rea.ip-ddns.com/privkey.pem`
  - `/etc/letsencrypt/options-ssl-nginx.conf`
  - `/etc/letsencrypt/ssl-dhparams.pem`

### Commande pour créer le ZIP final :
```bash
mkdir exerciceadminlinux_SOLIS_Andrea

# Copier tous les fichiers nécessaires
sudo cp /etc/nginx/conf.d/wordpress.conf exerciceadminlinux_SOLIS_Andrea/
sudo cp /etc/nginx/nginx.conf exerciceadminlinux_SOLIS_Andrea/
sudo cp /var/www/html/wordpress/wp-config.php exerciceadminlinux_SOLIS_Andrea/
sudo cp /etc/php/8.3/fpm/php.ini exerciceadminlinux_SOLIS_Andrea/
sudo cp /var/log/nginx/access.log exerciceadminlinux_SOLIS_Andrea/
sudo cp /var/log/nginx/error.log exerciceadminlinux_SOLIS_Andrea/
sudo cp -L /etc/letsencrypt/live/wordpress.rea.ip-ddns.com/fullchain.pem exerciceadminlinux_SOLIS_Andrea/
sudo cp -L /etc/letsencrypt/live/wordpress.rea.ip-ddns.com/privkey.pem exerciceadminlinux_SOLIS_Andrea/

# Créer le ZIP final
sudo tar -czf exerciceadminlinux_SOLIS_Andrea.tar.gz exerciceadminlinux_SOLIS_Andrea/
```

---

## 🎯 Résultat Final

✅ Site WordPress fonctionnel : `https://wordpress.rea.ip-ddns.com`  
✅ SSL configuré avec Let's Encrypt  
✅ Base de données MariaDB sécurisée  
✅ Plan de sauvegarde automatisé  
✅ Tous les livrables prêts pour l'examen
