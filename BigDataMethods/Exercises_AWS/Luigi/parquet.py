from pyspark import SparkContext
from pyspark.sql import *    
import sys
if __name__ == "__main__":

    sc = SparkContext(appName="Parquet")
    spark = SQLContext(sc)
    profeco = spark.read.csv('s3://daniel-sharp/profeco/profeco.csv', header =True)     
    profeco.write.format('parquet').option("compression", "gzip").save("s3://daniel-sharp/profeco/profeco_gzip", mode='OVERWRITE')
    sc.stop()