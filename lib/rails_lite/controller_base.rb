require 'erb'
require 'active_support/inflector'
require 'active_support/core_ext'
require_relative 'params'
require_relative 'session'


class ControllerBase
  attr_reader :params, :req, :res

  # setup the controller
  def initialize(req, res, route_params = {})
    @params = Params.new(@req)
    @req, @res = req, res
    @already_rendered = false
  end

  # populate the response with content
  # set the responses content type to the given type
  # later raise an error if the developer tries to double render
  def render_content(content, type)
    raise if already_rendered?

    @res.content_type = type
    @res.body = content
    session.store_session(@res)

    @already_rendered = true
  end

  # helper method to alias @already_rendered
  def already_rendered?
    @already_rendered
  end

  # set the response status code and header
  def redirect_to(url)
    session.store_session(@res)
    @res.set_redirect(WEBrick::HTTPStatus::TemporaryRedirect, url)
    @already_rendered = true
  end

  # use ERB and binding to evaluate templates
  # pass the rendered html to render_content
  def render(template_name)
    controller_name = self.class.to_s.underscore
    contents = File.read("views/#{controller_name}/#{template_name}.html.erb")

    erb = ERB.new(contents).result(binding)
    render_content(erb, 'text/html')
  end

  # method exposing a `Session` object
  def session
    @session ||= Session.new(@req)
  end

  # use this with the router to call action_name (:index, :show, :create...)
  def invoke_action(name)
    self.send(name)
    render(name) unless already_rendered?
  end
end
