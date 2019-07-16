require 'test_helper'

class AuthorizerAccessDeniedTest < ActiveSupport::TestCase
  test 'one required and none set' do
    err = SimonSays::Authorizer::Denied.new(:roles, %w(foo), [])

    assert_equal 'Access denied: foo is required; however, you have no roles set', err.message
  end

  test 'two required and none set' do
    err = SimonSays::Authorizer::Denied.new(:roles, %w(foo bar), [])

    assert_equal 'Access denied: foo or bar are required; however, you have no roles set', err.message
  end

  test 'three required and none set' do
    err = SimonSays::Authorizer::Denied.new(:roles, %w(foo bar baz), [])

    assert_equal 'Access denied: foo, bar, or baz are required; however, you have no roles set', err.message
  end

  test 'one required and one set' do
    err = SimonSays::Authorizer::Denied.new(:roles, %w(foo), %w(qux))

    assert_equal 'Access denied: foo is required; however, you have qux roles set', err.message
  end

  test 'two required and one set' do
    err = SimonSays::Authorizer::Denied.new(:roles, %w(foo bar), %w(qux))

    assert_equal 'Access denied: foo or bar are required; however, you have qux roles set', err.message
  end

  test 'three required and one set' do
    err = SimonSays::Authorizer::Denied.new(:roles, %w(foo bar baz), %w(qux))

    assert_equal 'Access denied: foo, bar, or baz are required; however, you have qux roles set', err.message
  end

  test 'one required and two set' do
    err = SimonSays::Authorizer::Denied.new(:roles, %w(foo), %w(qux quux))

    assert_equal 'Access denied: foo is required; however, you have qux and quux roles set', err.message
  end

  test 'two required and two set' do
    err = SimonSays::Authorizer::Denied.new(:roles, %w(foo bar), %w(qux quux))

    assert_equal 'Access denied: foo or bar are required; however, you have qux and quux roles set', err.message
  end

  test 'three required and two set' do
    err = SimonSays::Authorizer::Denied.new(:roles, %w(foo bar baz), %w(qux quux))

    assert_equal 'Access denied: foo, bar, or baz are required; however, you have qux and quux roles set', err.message
  end

  test 'one required and three set' do
    err = SimonSays::Authorizer::Denied.new(:roles, %w(foo), %w(qux quux quuz))

    assert_equal 'Access denied: foo is required; however, you have qux, quux, and quuz roles set', err.message
  end

  test 'two required and three set' do
    err = SimonSays::Authorizer::Denied.new(:roles, %w(foo bar), %w(qux quux quuz))

    assert_equal 'Access denied: foo or bar are required; however, you have qux, quux, and quuz roles set', err.message
  end

  test 'three required and three set' do
    err = SimonSays::Authorizer::Denied.new(:roles, %w(foo bar baz), %w(qux quux quuz))

    assert_equal 'Access denied: foo, bar, or baz are required; however, you have qux, quux, and quuz roles set', err.message
  end
end
