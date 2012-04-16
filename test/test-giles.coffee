giles = require('../giles')
fs = require 'fs'
path = require 'path'
describe 'watch', () ->
  it 'should assert', () ->
    [1,2,3].indexOf(5).should.equal -1

describe 'giles', () ->
  it 'should get extensions', () ->
    giles.parseFileName('test.test').should.eql(['test','.test'])
    giles.parseFileName('test').should.eql(['test',''])
    giles.parseFileName('.test').should.eql(['','.test'])
    giles.parseFileName('file.min.css').should.eql(['file.min','.css'])
    giles.parseFileName('file.really.long-whatever-name.out').should.eql(['file.really.long-whatever-name', '.out'])

giles.addCompiler '.test-giles-compiler', '.test-giles-compiler-out', (contents) ->
  contents.substr(0,5)
describe 'new compiler', () ->
  it 'should compile correctly', () ->
    result = giles.compileFile(__dirname+'/test.test-giles-compiler')
    result.content.should.equal result.originalContent.substr(0,5)
    result.outputFile.indexOf('test.test-giles-compiler-out').should.not.eql(-1)
    result.inputFile.indexOf('test.test-giles-compiler').should.not.eql(-1)
  
    giles.addCompiler ['.test-giles-compiler', '.test-giles-compiler2'], '.test-giles-compiler-out', (contents) ->
      contents.substr(0,6)
    result = giles.compileFile(__dirname+'/test.test-giles-compiler')
    result.content.should.equal result.originalContent.substr(0,6)

    giles.addCompiler '.test-giles-compiler', '.test-giles-compiler-out', (contents) ->
      contents.substr(0,5)

describe 'building', () ->
  it 'should build an individual file', () ->
    giles.compile(__dirname+'/test.test-giles-compiler')
    contents = fs.readFileSync(__dirname+'/test.test-giles-compiler-out', 'utf8')
    contents.length.should.equal(5)


createFixture = (filename, content, done, callback)->
  file = __dirname+"/"+filename
  console.log('creating fixture: '+ file)
  fs.writeFileSync(file, content, 'utf8')
  setTimeout( () ->
    callback()
    fs.unlinkSync(file)
    done()
  , 100)

giles.watch(__dirname, {})
describe 'watch', () ->
  #  it 'should build a file when it has changed', (done) ->
  #    origContent = 'this is a tmp file'
  #    createFixture 'tmp.test-giles-compiler', origContent, done, () ->
  #      outfile = __dirname+'/tmp.test-giles-compiler-out'
  #      content = fs.readFileSync(outfile, 'utf8')
  #      content.should.equal(origContent.substr(0,5))
  #      setTimeout(() ->
  #        fs.unlinkSync(outfile)
  #      ,0)

  it 'should work with subdirs', (done) ->
    origContent = 'this is a tmp file'
    fs.mkdirSync(__dirname+'/tmp')

    setTimeout( () ->
      createFixture 'tmp/tmp.test-giles-compiler', origContent, done, () ->
        outfile = __dirname+'/tmp/tmp.test-giles-compiler-out'
        content = fs.readFileSync(outfile, 'utf8')
        content.should.equal(origContent.substr(0,5))
        setTimeout(() ->
          fs.unlinkSync(outfile)
          fs.rmdirSync(__dirname+'/tmp')
        ,0)
    ,100)