require 'rack/when/builder'

describe 'An environment sensitive rack builder' do
  before do
    stub_const("ENV",{})
  end

  describe '#mount rack_up' do
    let(:builder)       { Rack::When::Builder.new @env, block }
    let(:block)         { double "block" }
    let(:mount_builder) { builder.mount }

    it 'will run the block when enviroment matches' do
      @env = :development
      expect(block).to receive(:call)
      mount_builder
    end

    it 'will run the block when enviroment matches regardless of case' do
      @env = 'DeVelopment'
      expect(block).to receive(:call)
      mount_builder
    end

    it 'will run the block when enviroment matches partially' do
      @env = :dev
      expect(block).to receive(:call)
      mount_builder
    end

    it 'will ignore the block on mismatch' do
      @env = :staging
      mount_builder
    end
  end

  describe '#current_env_matches?' do
    shared_examples_for 'matching environment' do
      it 'is true when matched' do
        expect(Rack::When::Builder.new :development,  double ).to have_matching_env
        expect(Rack::When::Builder.new 'development', double ).to have_matching_env
        expect(Rack::When::Builder.new 'DeVelopment', double ).to have_matching_env
      end

      it 'is true when matched as partial' do
        expect(Rack::When::Builder.new :dev,  double ).to have_matching_env
        expect(Rack::When::Builder.new 'dev', double ).to have_matching_env
      end

      it 'is false when mismatched' do
        expect(Rack::When::Builder.new :staging, double ).to_not have_matching_env
      end
    end

    context 'environment set by RACK_ENV' do
      before { ENV['RACK_ENV'] == 'development' }

      it_should_behave_like 'matching environment'
    end

    context 'environment set by RAILS_ENV' do
      before { ENV['RAILS_ENV'] == 'development' }

      it_should_behave_like 'matching environment'
    end

    context 'environment not set' do
      it_should_behave_like 'matching environment'
    end

    it 'matches when one of multiple envs match' do
      ENV['RACK_ENV'] = 'custom'
      expect(Rack::When::Builder.new :dev,    :custom, double ).to have_matching_env
      expect(Rack::When::Builder.new :custom, :test,   double ).to have_matching_env
      expect(Rack::When::Builder.new :dev,    :test,   double ).to_not have_matching_env
    end
  end
end
