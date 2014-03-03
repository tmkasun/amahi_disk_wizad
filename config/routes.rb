AmahiDiskManager::Application.routes.draw do
  
  # The priority is based upon order of creation: first created -> highest priority.
  # See how all your routes lay out with "rake routes".

  # You can have the root of your site routed with "root"
  # root 'welcome#index'
  root :to =>  "welcome#index"
  scope 'tab/' do
    
    scope 'disks/' do
      get 'select' => 'disks#select_device'
      get 'file_system' => 'disks#select_fs'
      get 'manage' => 'disks#manage_disk'
      get 'complete' => 'disks#done'
    end
    
    resources :disks
    
 end

end
