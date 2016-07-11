# Roberto camina Bushwick

A ver si así me oriento en mi colonia adoptiva.

<img width="581" alt="screen shot 2016-07-04 at 11 28 09 pm" src="https://cloud.githubusercontent.com/assets/123365/16573249/95d25182-423f-11e6-8bc2-e825a8a91165.png">


## ¿Cómo se echa a andar?

Hay que [generar un polígono en geoJSON](http://geojson.io/#map=2/20.0/0.0), y guardarlo en `./polygon.geojson`, y luego:

```shell
bundle install

# Descarga la información de OSM
rake source

# Genera la información de cada calle
rake process

# Genera mapas estáticos de cada una
MAPBOX=some_token rake maps

# Y finalmente, crea los issues 
GITHUB=some_token rake issues
```


## Enumera las calles

```shell
rake process[print] | jq '.features[] | .properties.name'
```

## Longitud total

```shell
rake process[print] | jq ' [.[] | .length] | add '
```