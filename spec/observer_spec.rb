require 'spec_helper'

describe AuditedModelsObserver do

  describe ".observed_classes" do
    it "returns all mapped model class names" do
      AuditedModelsObserver.observed_classes.should eq(
        [AuditedModel, NestedAuditedModel]
      )
    end
  end
  
  context "when a mapped model is created" do
    let(:audited_model) { AuditedModel.new(description: "description") }
    
    it { expect { audited_model.save }.to change { LoggedModel.count }.from(0).to(1) }
    
    describe "log fields" do
      before { audited_model.save }
      subject { LoggedModel.first }
      
      specify(:what) do
        YAML.load(subject.what).should eq(
          {
            id: audited_model.id, 
            event: :create
          }
        ) 
      end

      its(:model_name) { should eq("AuditedModel") }
      its(:model_id) { should eq(audited_model.id) }
    end
  end
  
  context "when a mapped model is destroyed" do
    let(:audited_model) { AuditedModel.new(description: "description") }
    before { audited_model.save }
    
    it { expect { audited_model.destroy }.to change { LoggedModel.count }.from(1).to(2) }
    
    describe "log fields" do
      before { audited_model.destroy }
      subject { LoggedModel.last }
      
      specify(:what) do
        YAML.load(subject.what).should eq(
          {
            id: audited_model.id, 
            event: :destroy
          }
        ) 
      end

      its(:model_name) { should eq("AuditedModel") }
      its(:model_id) { should eq(audited_model.id) }
    end
  end
  
  context "when a mapped model has been added a nested" do
    let(:audited_model) { AuditedModel.new(description: "description") }
    
    describe "has_many association" do
      before { audited_model.save }
      
      it { 
        expect { 
          audited_model.update_attributes("nested_audited_models_attributes" => [{"nested_description" => "nested_description"}]) 
        }.to change { LoggedModel.count }.from(1).to(2) 
      }
      
      describe "log fields" do
        before { audited_model.update_attributes("nested_audited_models_attributes" => [{"nested_description" => "nested_description"}]) }
        subject { LoggedModel.last }
        
        specify(:what) do
          YAML.load(subject.what).should eq(
            {
              id: audited_model.id, 
              event: :update,
              nested_audited_models: [
                {id: NestedAuditedModel.last.id, event: :create}
              ]
            }
          ) 
        end
        
        its(:model_name) { should eq("AuditedModel") }
        its(:model_id) { should eq(audited_model.id) }
      end
    end
    
    describe "has_one association" do
      before { audited_model.save }
      
      it { 
        expect { 
          audited_model.update_attributes("has_one_audited_model_attributes" => {"description" => "description"}) 
        }.to change { LoggedModel.count }.from(1).to(2) 
      }
      
      describe "log fields" do
        before { audited_model.update_attributes("has_one_audited_model_attributes" => {"description" => "description"}) }
        subject { LoggedModel.last }
        
        specify(:what) do
          YAML.load(subject.what).should eq(
            {
              id: audited_model.id, 
              event: :update,
              has_one_audited_model: {
                id: HasOneAuditedModel.last.id, 
                event: :create
              }
            }
          ) 
        end
        
        its(:model_name) { should eq("AuditedModel") }
        its(:model_id) { should eq(audited_model.id) }
      end
    end
  end
  
  context "when a mapped model has been removed a nested" do
    describe "has_many association" do
      let(:nested) { NestedAuditedModel.new(nested_description: "nested description") }
      let(:audited_model) { AuditedModel.new(description: "description", nested_audited_models: [nested]) }
      before { audited_model.save }
      
      it { 
        expect { 
          audited_model.update_attributes("nested_audited_models_attributes" => [{"id" => nested.id, "_destroy"=>"1"}]) 
        }.to change { LoggedModel.count }.from(1).to(2) 
      }
      
      describe "log fields" do
        before { audited_model.update_attributes("nested_audited_models_attributes" => [{"id" => nested.id, "_destroy"=>"1"}]) }
        subject { LoggedModel.last }
        
        specify(:what) do
          YAML.load(subject.what).should eq(
            {
              id: audited_model.id, 
              event: :update,
              nested_audited_models: [
                {id: nested.id, event: :destroy}
              ]
            }
          ) 
        end
        
        its(:model_name) { should eq("AuditedModel") }
        its(:model_id) { should eq(audited_model.id) }
      end
    end
    
    describe "has_one association" do
      let(:has_one_audited_model) { HasOneAuditedModel.new(description: "desc") }
      let(:audited_model) { AuditedModel.new(description: "description", has_one_audited_model: has_one_audited_model) }
      before { audited_model.save }
    
      it { 
        expect { 
          audited_model.update_attributes("has_one_audited_model_attributes" => {"id" => has_one_audited_model.id, "_destroy"=>"1"}) 
        }.to change { LoggedModel.count }.from(1).to(2) 
      }
      
      describe "log fields" do
        before { audited_model.update_attributes("has_one_audited_model_attributes" => {"id" => has_one_audited_model.id, "_destroy"=>"1"}) }
        subject { LoggedModel.last }
        
        specify(:what) do
          YAML.load(subject.what).should eq(
            {
              id: audited_model.id, 
              event: :update,
              has_one_audited_model: {
                id: has_one_audited_model.id, 
                event: :destroy
              }
            }
          ) 
        end
        
        its(:model_name) { should eq("AuditedModel") }
        its(:model_id) { should eq(audited_model.id) }
      end
    end
  end
  
  context "when a mapped model is updated" do
    
    context "and it has no changes" do
      let(:audited_model) { AuditedModel.new(description: "description", ignored_field: "value") }
      before { audited_model.save }
      
      it { 
        pending "nao entendi, esta mostrando alteracao no model.thread??"
        expect { 
          audited_model.save 
          #audited_model.update_attributes("nested_audited_models_attributes" => [{"id" => nested.id, "nested_description" => "nested_description"}]) 
        }.to_not change { LoggedModel.count }.from(1) 
      }
    end
          
    context "and it has changes" do
      let(:nested) { NestedAuditedModel.new(nested_description: "nested description", ignored_field: "value") }
      let(:has_one_audited_model) { HasOneAuditedModel.new(description: "desc") }
      let(:audited_model) { 
        AuditedModel.new(description: "description", ignored_field: "value", has_one_audited_model: has_one_audited_model, nested_audited_models: [nested]) 
      }
      before { audited_model.save }
      
      context "in ignored and non ignored fields" do
        context "of main model" do
          it { 
            expect { 
              audited_model.update_attributes(description: "new description", ignored_field: "new value")   
            }.to change { LoggedModel.count }.from(1).to(2) 
          }
          
          describe "log fields" do
            before { audited_model.update_attributes(description: "new description", ignored_field: "new value") }
            subject { LoggedModel.last }
            
            specify(:what) do
              YAML.load(LoggedModel.last.what).should eq(
                {
                  id: audited_model.id, 
                  event: :update,
                  description: {from: "description", to: "new description"}
                }
              ) 
            end
            
            its(:model_name) { should eq("AuditedModel") }
            its(:model_id) { should eq(audited_model.id) }
          end
        end
        
        context "of nested has many association model" do
          before { audited_model.nested_audited_models.first.nested_description = "new description" }
          
          it { expect { audited_model.save }.to change { LoggedModel.count }.from(1).to(2) }
          
          describe "log fields" do
            before { audited_model.save }
            subject { LoggedModel.last }
            
            specify(:what) do
              YAML.load(LoggedModel.last.what).should eq(
                {
                  id: audited_model.id, 
                  event: :update,
                  nested_audited_models: [
                    {
                      id: NestedAuditedModel.last.id, 
                      event: :update,
                      nested_description: {from: "nested description", to: "new description"}
                    }
                  ]
                }
              ) 
            end
            
            its(:model_name) { should eq("AuditedModel") }
            its(:model_id) { should eq(audited_model.id) }
          end
        end
        
        context "of nested has one association model" do
          before { audited_model.has_one_audited_model.description = "new description" }
          
          it { expect { audited_model.save }.to change { LoggedModel.count }.from(1).to(2) }
          
          describe "log fields" do
            before { audited_model.save }
            subject { LoggedModel.last }
            
            specify(:what) do
              YAML.load(subject.what).should eq(
                {
                  id: audited_model.id, 
                  event: :update,
                  has_one_audited_model: {
                    id: has_one_audited_model.id, 
                    event: :update,
                    description: {from: "desc", to: "new description"}
                  }
                }
              ) 
            end
            
            its(:model_name) { should eq("AuditedModel") }
            its(:model_id) { should eq(audited_model.id) }
          end
        end
      end
      
      context "only in ignored fields" do
        let(:audited_model) { AuditedModel.new(description: "description", ignored_field: "value") }
        
        context "of main model" do
          before { audited_model.save }
          
          it { 
            expect { 
              audited_model.update_attributes(ignored_field: "new value") 
            }.to_not change { LoggedModel.count }.from(1) 
          }
        end
        
        context "of nested has many association model" do
          it "TODO" 
        end
        
        context "of nested has one association model" do
          it "TODO" 
        end
        
      end
    end
  end
end
