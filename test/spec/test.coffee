# global describe, it

do ->
  'use strict'
  describe 'Give it some context', ->
    describe 'maybe a bit more context here', ->
      it 'should run here few assertions', ->
        example = true
        expect(example).to.be.true
