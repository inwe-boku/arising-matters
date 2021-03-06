library(ggplot2)
library(tidyverse)

colors<-c("#6e9b9e", "#c72321")


#hh..hub_height
rinne_derivative<-function(rotor, hh, age){
  
  max_power <- (rotor^2*pi)*(620*log(hh) + 182*sqrt(age) - 1005) / (2*1.68) 
  return(max_power/10^6)
  
}

rinne_total_costs<-function(power, r, hh, age){
  return(10^3*power * (610*log(hh)-1.68*power*10^6/(r^2*pi)+182*sqrt(age)-1005))
}

plot_feasible_infeasible_curve<-function(rotor, hub_height, age, filename, power = 0)
{
  
  
  x_max<-rinne_derivative(rotor, hub_height, age)
  y_max<-rinne_total_costs(x_max, rotor, hub_height ,age)/10^6
  
  
  power_range_feasible<-seq(0,x_max,0.1)
  feasible_curve<-tibble(power_range=power_range_feasible,
                         total_costs=rinne_total_costs(power_range_feasible,
                                                       rotor,
                                                       hub_height,
                                                       age)/10^6,
                         Region="Plausible")
  
  power_range_infeasible<-seq(x_max,10,0.1)
  infeasible_curve<-tibble(power_range=power_range_infeasible,
                           total_costs=rinne_total_costs(power_range_infeasible,
                                                         rotor,
                                                         hub_height,
                                                         age)/10^6,
                           Region="Implausible"
  )
  
  if(power != 0){
    
    cost_max_power=rinne_total_costs(power,
                                     rotor,
                                     hub_height,
                                     age)/10^6
    
    figure<-bind_rows(feasible_curve, infeasible_curve) %>% 
      ggplot(aes(x=power_range,y=total_costs)) + 
      geom_line(aes(col=Region),size=2) +
      xlab("Power (MW)") + ylab("Total costs of Turbine (Million Euro)") + 
      geom_point(aes(x=x_max,y=y_max),size=2) +
      scale_color_manual(values=c(colors[1],colors[2])) + 
      geom_point(aes(x=power, y=cost_max_power),size=6,shape=4, stroke=3)
    
    
  } else{
    
    
    
    
    figure<-bind_rows(feasible_curve, infeasible_curve) %>% 
      ggplot(aes(x=power_range,y=total_costs)) + 
      geom_line(aes(col=Region),size=2) +
      xlab("Power (MW)") + ylab("Total costs of Turbine (Million Euro)") + 
      geom_point(aes(x=x_max,y=y_max),size=2) +
      scale_color_manual(values=c(colors[1],colors[2]))
  }
  
  plot(figure)
  ggsave(paste0("../figures/", filename))
  
}
