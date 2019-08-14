#--- Usar espejo CRAN del ITAM ---
options(repos="http://cran.itam.mx/")

library(R2OpenBUGS)
library(R2jags)
library(ggplot2)

#-Working directory-
wdir<-"C:/Users/rener/Documents/Master_Data_Science/Modelos_Generalizados/TrabajoFinal"
setwd(wdir)

#--- Funciones utiles ---
prob<-function(x){
  out<-min(length(x[x>0])/length(x),length(x[x<0])/length(x))
  out
}

#--- Bse de datos ---
teledensidad = readxl::read_excel('TELEDENSIDAD_IFT.xlsx')

teledensidad.ts = ts(teledensidad, start = c(2013,1), end = c(2018,2), frequency = 4)
plot(teledensidad.ts[,-c(1,2)])

teledensidad$TRIM = c(seq(1:nrow(teledensidad)))

GGally::ggpairs(teledensidad[c(3,4,9,6,11)])

#CODIGO BUGS
n = nrow(teledensidad)

x = as.matrix(teledensidad[c(11,9,6)])
cor(x)
#-Defining data-
#LEVEL
data = list("n"     = n,
            "y"     = teledensidad$TELEDENSIDAD,
            "x"     = x)
#Standarized
data = list("n"     = n,
            "y"     = teledensidad$TELEDENSIDAD/100,
            "x"     = scale(x)[1:n,])

#Log
data = list("n"     = n,
            "y"     = log(teledensidad$TELEDENSIDAD/(100-teledensidad$TELEDENSIDAD)),
            "x"     = log(x))

#-Inits Estático-
inits=function(){list(beta  = rep(0, 3), 
                      tau   = 1,
                      alpha = 0,
                      tau.p = 1,
                      pf    = rep(1,n),
                      yf    = rep(1,n))}

#-Inits Dinámico-
inits<-function(){list(alpha = 0,
                       beta  = matrix(0, nrow=3, ncol=n),
                       tau   = 1,
                       tau.p = 1,
                       tau.b = 1,
                       yf    = rep(1,n),
                       pf    = rep(1,n))}


#-Selecting parameters to monitor
parameters<-c("beta","yf", "alpha", "pf", "tau.b")

start = Sys.time()

final.bugs.sim = bugs(data,inits,parameters,model.file="Final.txt",
                       n.iter=20000,n.chains=2,n.burnin=2000, debug = T)

end = Sys.time()

end - start
#BUGS
out.bugs = final.bugs.sim$sims.list

z<-out.bugs$beta[,3]
par(mar=c(2,2,2,2))
par(mfrow=c(2,2))
plot(z,type="l")
plot(cumsum(z)/(1:length(z)),type="l")
hist(z,freq=FALSE)
acf(z)

#Resumen (estimadores)
#OpenBUGS
out.sum<-final.bugs.sim$summary

#Tabla resumen
out.sum.t<-out.sum[grep("alpha|beta",rownames(out.sum)),c(1,3,7)]
out.sum.t<-cbind(out.sum.t,apply(out.bugs$beta,2,prob))
dimnames(out.sum.t)[[2]][4]<-"prob"
print(out.sum.t)

#BUGS

#DIC
out.dic<-final.bugs.sim$DIC
print(out.dic)


#Predictions
out.yf<-out.sum[grep("yf",rownames(out.sum)),]
y<-data$y
ymin<-min(y,out.yf[,c(1,3,7)])
ymax<-max(y,out.yf[,c(1,3,7)])

#x1 vs. y
x<-data$x[,1]
par(mfrow=c(1,1))
plot(x,y,type="p",col="grey50",ylim=c(ymin,ymax))
points(x,out.yf[,1],col=2,pch=16,cex=0.5)
segments(x,out.yf[,3],x,out.yf[,7],col=2)
#x2 vs. y
x<-data$x[,2]
par(mfrow=c(1,1))
plot(x,y,type="p",col="grey50",ylim=c(ymin,ymax))
points(x,out.yf[,1],col=2,pch=16,cex=0.5)
segments(x,out.yf[,3],x,out.yf[,7],col=2)
#x3 vs. y
x<-data$x[,3]
par(mfrow=c(1,1))
plot(x,y,type="p",col="grey50",ylim=c(ymin,ymax))
points(x,out.yf[,1],col=2,pch=16,cex=0.5)
segments(x,out.yf[,3],x,out.yf[,7],col=2)
#t vs. y
x<-teledensidad$TRIM
par(mfrow=c(1,1))
plot(x,y,type="p",col="grey50",ylim=c(ymin,ymax))
points(x,round(out.yf[,1]),col=2,pch=16,cex=0.5)
segments(x,out.yf[,3],x,out.yf[,7],col=2)
par(mfrow=c(1,1))
plot(x,y,type="l",col="grey50",ylim=c(ymin,ymax))
lines(x,round(out.yf[,1],2),col=2,cex=0.5)
lines(x,round(out.yf[,3],2),col=2,lty=2)
lines(x,round(out.yf[,7],2),col=2,lty=2)

#betas
out.beta<-out.sum[grep("beta",rownames(out.sum)),]
par(mfrow=c(2,2))
plot(out.beta[1:22,1],type="l", main = 'Beta 1')
plot(out.beta[23:44,1],type="l", main = 'Beta 2')
plot(out.beta[45:66,1],type="l", main = 'Beta 3')
plot(out.beta[67:88,1],type="l", main = 'Beta 4')

#alpha
out.alpha<-out.sum[grep("alpha",rownames(out.sum)),]
par(mfrow=c(1,1))
plot(rep(out.alpha[1],n),type="l", main = 'Alpha')
lines(rep(out.alpha[2],n), col = 2, lty = 2)
