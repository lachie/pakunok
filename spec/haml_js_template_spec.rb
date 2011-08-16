require 'spec_helper'
require 'tilt'
require 'pakunok/haml_js_template'

describe 'HAML-JS processor' do
  def template haml, file = "file.js.hamljs"
    Pakunok::HamlJsTemplate.new(file) { haml }
  end

  def render haml, file = "file.js.hamljs"
    template(haml, file).render
  end

  it 'should have default mime type' do
    Pakunok::HamlJsTemplate.default_mime_type.should == 'application/javascript'
  end

  describe 'rendering' do
    subject { render "#main= 'quotes'\n  #inner= name", 'myTemplate.js.hamljs' }

    it { should include "function (locals) {" }

    it 'should make template available for JavaScript' do
      context = ExecJS.compile(subject)
      html = context.eval("Templates.myTemplate({name: 'dima'})")
      html.should include '<div id="main">'
      html.should include 'dima'
    end

  end

  describe 'template naming for' do
    {
      'file'                      => 'file',
      'file.js.erb.hamljs'        => 'file',
      'file-with-dash.hamljs'     => 'fileWithDash',
      'file_with_underscore'      => 'fileWithUnderscore',
      'dir/foo_bar'               => 'dir_fooBar',
      'win\\dir\\foo_bar'         => 'win_dir_fooBar',
      'd1/d2/foo_bar.js.a.b.c.d'  => 'd1_d2_fooBar'
    }.each_pair do |file, name|
      it "#{file} should be #{name}" do
        template('#main', file).client_name.should == name
      end
    end

  end

  describe 'serving' do
    subject { assets }
    it { should serve 'haml/haml-foo-bar.js' }
    it { should serve 'haml/not-haml.js' }
  end
end
