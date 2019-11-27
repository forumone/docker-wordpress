# About this Image

Images built from this repository are used as bases for serving WordPress websites. They differ from the Docker Hub's `wordpress` image in two ways:

1. These images do not include a copy of the WordPress sources. We expect users of this image to copy the WordPress sources from version control or install via Composer.
2. These images include a small utility, `f1-ext-install`, to simplify the task of installing common extensions. For example, to install Memcached, one only needs to add this to their Dockerfile:

   ```sh
   f1-ext-install pecl:memcached
   ```

## PHP Versions and Tags

- Currently supported by PHP:
  - `7.3`, `7.3-xdebug`
  - `7.2`, `7.2-xdebug`
  - `7.1`, `7.1-xdebug`

- End-of-life for legacy projects:
  - `7.0`, `7.0-xdebug`
  - `5.6`, `5.6-xdebug`

Images tagged with `-xdebug` contain XDebug installed but disabled; at runtime use `docker-php-ext-enable xdebug` to enable.

The tags `7`, `7-debug`, `5`, and `5-debug` are available for quick testing when a specific version isn't needed.

# License

Like the [base PHP image](https://github.com/docker-library/php) we use, this project is available under the terms of the MIT license. See [LICENSE](LICENSE) for more details.