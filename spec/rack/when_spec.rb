require 'rack/when'

describe 'setting up for environments' do
  [:development, :test, :staging, :production].each do |env|
    before do
      allow(Rack::When::Builder).to receive(:new).and_return(builder)
    end

    let(:builder) { double "builder", mount: nil }
    let(:block)   { double "block" }

    context "implicit #{env}" do
      it 'sets up a builder with the environment and the current context as rackup' do
        Rack::When.send env, &(block = -> { })
        expect(Rack::When::Builder).to have_received(:new).with(env.to_sym,block)
      end

      it 'mounts the builder with caller as rackup' do
        Rack::When.send(env) { }
        expect(builder).to have_received(:mount)
      end
    end

    context "explicit #{env}" do
      it 'sets up a builder with the environment and the current context as rackup' do
        Rack::When.environment env, &(block = -> { })
        expect(Rack::When::Builder).to have_received(:new).with(env.to_sym,block)
      end

      it 'mounts the builder with caller as rackup' do
        Rack::When.environment(env) { }
        expect(builder).to have_received(:mount)
      end
    end

  end
end
