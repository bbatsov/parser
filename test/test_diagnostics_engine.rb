require 'minitest/autorun'
require 'parser'

class TestDiagnosticsEngine < MiniTest::Unit::TestCase
  def setup
    @sfile  = Parser::SourceFile.new('(source)')
    @sfile.source = 'foobar'

    @engine = Parser::DiagnosticsEngine.new

    @queue  = []
    @engine.consumer = ->(diag) { @queue << diag }
  end

  def test_process_warnings
    warn = Parser::Diagnostic.new(:warning, "foo", @sfile, 1..2)
    @engine.process(warn)

    assert_equal [warn], @queue
  end

  def test_ignore_warnings
    @engine.ignore_warnings = true

    warn = Parser::Diagnostic.new(:warning, "foo", @sfile, 1..2)
    @engine.process(warn)

    assert_equal [], @queue
  end

  def test_all_errors_are_fatal
    @engine.all_errors_are_fatal = true

    error = Parser::Diagnostic.new(:error, "foo", @sfile, 1..2)

    assert_raises Parser::SyntaxError do
      @engine.process(error)
    end

    assert_equal [error], @queue
  end

  def test_all_errors_are_collected
    error = Parser::Diagnostic.new(:error, "foo", @sfile, 1..2)
    @engine.process(error)

    assert_equal [error], @queue
  end

  def test_fatal_error
    fatal = Parser::Diagnostic.new(:fatal, "foo", @sfile, 1..2)

    assert_raises Parser::SyntaxError do
      @engine.process(fatal)
    end

    assert_equal [fatal], @queue
  end
end