AmahiDiskManager::Application.routes.draw do
  
  # The priority is based upon order of creation: first created -> highest priority.
  # See how all your routes lay out with "rake routes".

  # You can have the root of your site routed with "root"
  # root 'welcome#index'
  root :to =>  "welcome#index"
  scope 'tab/' do
    
    resources :disks
        
  end

end
