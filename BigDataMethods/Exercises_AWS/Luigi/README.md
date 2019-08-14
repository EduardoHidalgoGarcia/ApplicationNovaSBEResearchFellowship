### Pipeline Luigi para análisis de Quien es Quien en los Precios  
#### Francisco Bahena, Cristian Challu, Eduardo Hidalgo, Daniel Sharp  

Para ejecutar el script es necesario instalar las librerías contenidas en el requirements.txt. Posteriormente se requiere de correr el siguiente comando en la terminal:  

```
PYTHONPATH="." luigi --module pipeline StartPipeline --cluster-name "Cluster Profeco" --keyname "\<Llave_para_cluster\>" --subnet-id '\<Subnet_id\>' --region-id '\<Región_de_servidores\>' --s3-url-log '\<Dirección_en_S3_para_logs\>' --local-scheduler
```  

Especificamente, para la ejecución en nuestro equipo, se utilizó el siguiente comando:  

```
PYTHONPATH="." luigi --module pipeline StartPipeline --cluster-name "Cluster Profeco" --keyname "emr" --subnet-id 'subnet-380fbc62' --region-id 'us-west-2' --s3-url-log 's3://daniel-sharp/logs/' --local-scheduler
```  

Para dar seguimiento a la ejecución de las tareas, en la misma terminal, posterior a correr la instrucción de ejecución, se imprime el progreso en cada uno de los pasos del pipeline.  

Para una correcta ejecución del script, es necesario tener la carpeta de configs con el archivo 'emr-config.json' en la misma carpeta. Además, los archivo en la dirección de S3 a los que se hace referencia 's3://daniel-sharp/' se han hecho públicos para que cualquiera pueda ejecutar este script.  

