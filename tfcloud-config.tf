terraform { 
  cloud { 
    
    organization = "superdeboer" 

    workspaces { 
      name = "azure-resources" 
    } 
  } 
}