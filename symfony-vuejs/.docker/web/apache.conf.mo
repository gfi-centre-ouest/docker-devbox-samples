<VirtualHost *:80>
  ServerAdmin webmaster@{{DOCKER_DEVBOX_DOMAIN_PREFIX}}.{{DOCKER_DEVBOX_DOMAIN}}
  ServerName api.{{DOCKER_DEVBOX_DOMAIN_PREFIX}}.{{DOCKER_DEVBOX_DOMAIN}}
  DocumentRoot /var/www/html/backend/public/

  <Directory "/var/www/html/backend/public/">
    DirectoryIndex index.php

    AllowOverride All
    Order allow,deny
    Allow from all
    Require all granted

    # symfony configuration from https://github.com/symfony/recipes-contrib/blob/master/symfony/apache-pack/1.0/public/.htaccess
   
    # By default, Apache does not evaluate symbolic links if you did not enable this
    # feature in your server configuration. Uncomment the following line if you
    # install assets as symlinks or if you experience problems related to symlinks
    # when compiling LESS/Sass/CoffeScript assets.
    # Options FollowSymlinks

    # Disabling MultiViews prevents unwanted negotiation, e.g. "/index" should not resolve
    # to the front controller "/index.php" but be rewritten to "/index.php/index".
    <IfModule mod_negotiation.c>
        Options -MultiViews
    </IfModule>

    <IfModule mod_rewrite.c>
        RewriteEngine On

        # Determine the RewriteBase automatically and set it as environment variable.
        # If you are using Apache aliases to do mass virtual hosting or installed the
        # project in a subdirectory, the base path will be prepended to allow proper
        # resolution of the index.php file and to redirect to the correct URI. It will
        # work in environments without path prefix as well, providing a safe, one-size
        # fits all solution. But as you do not need it in this case, you can comment
        # the following 2 lines to eliminate the overhead.
        RewriteCond %{REQUEST_URI}::$1 ^(/.+)/(.*)::\2$
        RewriteRule ^(.*) - [E=BASE:%1]

        # Sets the HTTP_AUTHORIZATION header removed by Apache
        RewriteCond %{HTTP:Authorization} .
        RewriteRule ^ - [E=HTTP_AUTHORIZATION:%{HTTP:Authorization}]

        # Redirect to URI without front controller to prevent duplicate content
        # (with and without `/index.php`). Only do this redirect on the initial
        # rewrite by Apache and not on subsequent cycles. Otherwise we would get an
        # endless redirect loop (request -> rewrite to front controller ->
        # redirect -> request -> ...).
        # So in case you get a "too many redirects" error or you always get redirected
        # to the start page because your Apache does not expose the REDIRECT_STATUS
        # environment variable, you have 2 choices:
        # - disable this feature by commenting the following 2 lines or
        # - use Apache >= 2.3.9 and replace all L flags by END flags and remove the
        #   following RewriteCond (best solution)
        RewriteCond %{ENV:REDIRECT_STATUS} ^$
        RewriteRule ^index\.php(?:/(.*)|$) %{ENV:BASE}/$1 [R=301,L]

        # If the requested filename exists, simply serve it.
        # We only want to let Apache serve files and not directories.
        RewriteCond %{REQUEST_FILENAME} -f
        RewriteRule ^ - [L]

        # Rewrite all other queries to the front controller.
        RewriteRule ^ %{ENV:BASE}/index.php [L]
    </IfModule>

    <IfModule !mod_rewrite.c>
        <IfModule mod_alias.c>
            # When mod_rewrite is not available, we instruct a temporary redirect of
            # the start page to the front controller explicitly so that the website
            # and the generated links can still be used.
            RedirectMatch 307 ^/$ /index.php/
            # RedirectTemp cannot be used instead
        </IfModule>
    </IfModule>
  </Directory>

  SetEnvIf Authorization "(.*)" HTTP_AUTHORIZATION=$1

  <FilesMatch \.php$>
      SetHandler "proxy:fcgi://php.{{COMPOSE_NETWORK_NAME}}:9000"
  </FilesMatch>
</VirtualHost>

<VirtualHost *:80>
  ServerName {{DOCKER_DEVBOX_DOMAIN_PREFIX}}.{{DOCKER_DEVBOX_DOMAIN}}
  DocumentRoot /var/www/html/frontend/dist/

  <Directory "/var/www/html/frontend/dist/">
    DirectoryIndex index.html

    AllowOverride All
    Order allow,deny
    Allow from all
    Require all granted

    Options +FollowSymLinks
    RewriteEngine On
    RewriteBase /
    RewriteRule ^(static|VERSION|COMMITHASH)($|/) - [L]
    RewriteRule ^index\.html$ - [L]
    RewriteCond %{REQUEST_FILENAME} !-f
    RewriteCond %{REQUEST_FILENAME} !-d
    RewriteRule . /index.html [L]
  </Directory>

</VirtualHost>
