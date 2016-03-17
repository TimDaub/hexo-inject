Inject = require('../src/inject')
{ INJECTION_POINTS, API } = require('../src/const')
{ camalize } = require('../src/util')
sinon = require('sinon')

describe 'API', ->
  mock_hexo =
    extend:
      filter:
        register: sinon.stub()
      generator:
        register: sinon.stub()
    execFilter: sinon.stub()

  inject = null
  before ->
    inject = new Inject(mock_hexo)
    inject.register()

  describe 'register', ->
    it 'should expose API via `hexo.inject`', ->
      mock_hexo.extend.filter.register.calledWith('after_render:html').should.be.true
      mock_hexo.extend.filter.register.calledWith('after_init').should.be.true
      mock_hexo.extend.generator.register.calledWith('inject').should.be.true
      mock_hexo.inject.should.equal(inject)
    it.skip 'should execute `inject_ready` filter`', ->
      mock_hexo.execFilter.calledWith('inject_ready', inject, { context: mock_hexo })
        .should.be.true

  describe 'injection point', ->
    before ->
      API.forEach (i) -> sinon.stub(inject, i)
      inject._initAPI()
    after ->
      API.forEach (i) -> inject[i].restore()
      inject._initAPI()

    should_expose_api = (p) ->
      injection_point = p
      it injection_point, ->
        api = inject[camalize(injection_point)]
        api.should.be.an('object')
        API.forEach (i) ->
          api[i].should.be.a('function')
          api[i]('foo', 'bar', 'barz').should.equal(api, 'API calls should be chainable')
          inject[i].calledOn(inject).should.be.true
          inject[i].calledWith(injection_point, 'foo', 'bar', 'barz').should.be.true

    INJECTION_POINTS.forEach (i) -> should_expose_api(i)
