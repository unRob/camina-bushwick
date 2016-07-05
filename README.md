# Roberto camina Bushwick

A ver si así me oriento en mi colonia adoptiva.

<img width="581" alt="screen shot 2016-07-04 at 11 28 09 pm" src="https://cloud.githubusercontent.com/assets/123365/16573249/95d25182-423f-11e6-8bc2-e825a8a91165.png">


## Enumera las calles

```shell
rake process[geoJSON] | jq '.features[] | .properties.name'
```