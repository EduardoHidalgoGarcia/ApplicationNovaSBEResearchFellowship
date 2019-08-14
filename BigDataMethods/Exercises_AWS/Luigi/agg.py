

import sys
import os
import datetime
from pyspark.sql import *
from pyspark.sql import functions
from pyspark import SparkContext


sc = SparkContext(appName='agg')

spark = SQLContext(sc)

# Lectura de los datos
df = spark.read.parquet('s3a://daniel-sharp/profeco/profeco_gzip')

resumen = df.select('producto', 'precio').groupBy('producto').agg(functions.count('producto').alias("Count"),functions.mean("precio").alias("precio medio"))

# Hacemos coalesce para que tengamos un solo archivo de salida para estos
resumen.coalesce(1).write.csv('s3://daniel-sharp/profeco/agg',mode='OVERWRITE', header=True)

sc.stop()


