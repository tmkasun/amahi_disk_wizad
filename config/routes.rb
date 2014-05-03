AmahiDiskManager::Application.routes.draw do
  
  # The priority is based upon order of creation: first created -> highest priority.
  # See how all your routes lay out with "rake routes".

  # You can have the root of your site routed with "root"
  # root 'welcome#index'
  root :to =>  "welcome#index"
  scope 'tab/' do
    
    scope 'disks/' do
      match 'select' => 'disks#select_device',via: [:get,:post]
      match 'file_system' => 'disks#select_fs',via: [:get,:post]
      match 'manage' => 'disks#manage_disk',via: [:get,:post]
      match 'confirmation' => 'disks#confirmation',via: [:get,:post]
      get 'complete' => 'disks#done'
      get 'get_progress' => 'disks#operations_progress'
      get 'error' => 'disks#error'
      match 'process' => 'disks#process_disk', via: [:get,:post]
    end
    
    resources :disks
    
 end

end
