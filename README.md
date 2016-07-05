# Roberto camina Bushwick

A ver si así me oriento en mi colonia adoptiva.

<img width="583" alt="screen shot 2016-07-04 at 10 48 16 pm" src="https://cloud.githubusercontent.com/assets/123365/16572698/6e18de96-4239-11e6-8360-abfe3acec634.png">

## Enumera las calles

```shell
rake process[geoJSON] | jq '.features[] | .properties.name'
```

