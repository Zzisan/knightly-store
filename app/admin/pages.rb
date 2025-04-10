ActiveAdmin.register Page do
    permit_params :title, :slug, :content
    
    index do
      selectable_column
      id_column
      column :title
      column :slug
      actions
    end
    
    filter :title
    filter :slug
    
    form do |f|
      f.inputs "Page Details" do
        f.input :title
        f.input :slug, hint: "Use a unique identifier (e.g., 'about' or 'contact')"
        f.input :content, as: :text, hint: "HTML content is allowed"
      end
      f.actions
    end
  end
  