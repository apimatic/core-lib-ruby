require 'minitest/autorun'
require 'apimatic_core'

class ComparisonHelperTest < Minitest::Test
  include CoreLibrary

  def test_match_headers
    test_cases = [
      [{}, {}, false, true],
      [{ 'content-type': 'application/json' }, { 'content-type': 'application/json' }, false, true],
      [{ 'content-type': 'APPLICATION/JSON' }, { 'content-type': 'application/json' }, false, false],
      [{ 'content-type': 'application/json' }, { 'CONTENT-TYPE': 'application/json' }, false, true],
      [{ 'content-type': 'application/json' }, { 'content-type': 'APPLICATION/JSON' }, false, false],
      [{ 'content-type': 'application/json', 'accept': 'application/json' }, { 'content-type': 'application/json' }, false, false],
      [{ 'content-type': 'application/json', 'accept': 'application/json' }, { 'content-type': 'application/json' }, true, false],
      [{ 'content-type': 'application/json' }, { 'Connection': 'close' }, true, false],
      [{ 'content-type': 'application/json' }, { 'content-type': 'application/json', 'accept': 'application/json' }, true, true]
    ]

    test_cases.each do |arr|
      expected_headers = arr[0]
      received_headers = arr[1]
      should_allow_extra = arr[2]
      expected_output = arr[3]

      match_headers_output = ComparisonHelper.match_headers(expected_headers, received_headers, allow_extra: should_allow_extra)

      assert(match_headers_output == expected_output)
    end
  end

  def test_match_body
    test_cases = [
      [[100, 500, 300, 200, 400], '[100, 500, 300, 200, 400]', true, true, true, false], # 0
      [[100, 500, 300, 200, 400], [100, 500, 300, 200, 400], true, true, true, true], # 1
      [[100, 500, 300, 200, 400], [100, 500, 300, 200, 400], true, true, false, true], # 2
      [[100, 500, 300, 200, 400], [100, 500, 300, 200, 400], true, false, true, true], # 3
      [[100, 500, 300, 200, 400], [100, 500, 300, 200, 400], true, false, false, true], # 4
      [[100, 500, 300, 200, 400], [100, 500, 300, 200, 400], false, true, true, true], # 5
      [[100, 500, 300, 200, 400], [100, 500, 300, 200, 400], false, true, false, true], # 6
      [[100, 500, 300, 200, 400], [100, 500, 300, 200, 400], false, false, true, true], # 7
      [[100, 500, 300, 200, 400], [100, 500, 300, 200, 400], false, false, false, true], # 8

      [[101, 500, 300, 200, 400], [100, 500, 300, 200, 400], true, true, true, false], # 9
      [[101, 500, 300, 200, 400], [100, 500, 300, 200, 400], true, true, false, false], # 10
      [[101, 500, 300, 200, 400], [100, 500, 300, 200, 400], true, false, true, false], # 11
      [[101, 500, 300, 200, 400], [100, 500, 300, 200, 400], true, false, false, false], # 12
      [[101, 500, 300, 200, 400], [100, 500, 300, 200, 400], false, true, true, false], # 13
      [[101, 500, 300, 200, 400], [100, 500, 300, 200, 400], false, true, false, false], # 14
      [[101, 500, 300, 200, 400], [100, 500, 300, 200, 400], false, false, true, false], # 15
      [[101, 500, 300, 200, 400], [100, 500, 300, 200, 400], false, false, false, false], # 16

      [[100, 500, 300, 200, 400], [101, 500, 300, 200, 400], true, true, true, false], # 17
      [[100, 500, 300, 200, 400], [101, 500, 300, 200, 400], true, true, false, false], # 18
      [[100, 500, 300, 200, 400], [101, 500, 300, 200, 400], true, false, true, false], # 19
      [[100, 500, 300, 200, 400], [101, 500, 300, 200, 400], true, false, false, false], # 20
      [[100, 500, 300, 200, 400], [101, 500, 300, 200, 400], false, true, true, false], # 21
      [[100, 500, 300, 200, 400], [101, 500, 300, 200, 400], false, true, false, false], # 22
      [[100, 500, 300, 200, 400], [101, 500, 300, 200, 400], false, false, true, false], # 23
      [[100, 500, 300, 200, 400], [101, 500, 300, 200, 400], false, false, false, false], # 24

      [[100, 500, 300, 200, 400], [500, 100, 300, 200, 400], true, true, true, false], # 25
      [[100, 500, 300, 200, 400], [500, 100, 300, 200, 400], true, true, false, false], # 26
      [[100, 500, 300, 200, 400], [500, 100, 300, 200, 400], true, false, true, true], # 27
      [[100, 500, 300, 200, 400], [500, 100, 300, 200, 400], true, false, false, true], # 28
      [[100, 500, 300, 200, 400], [500, 100, 300, 200, 400], false, true, true, false], # 29
      [[100, 500, 300, 200, 400], [500, 100, 300, 200, 400], false, true, false, false], # 30
      [[100, 500, 300, 200, 400], [500, 100, 300, 200, 400], false, false, true, true], # 31
      [[100, 500, 300, 200, 400], [500, 100, 300, 200, 400], false, false, false, true], # 32

      [[100, 500, 300, 200, 400], [100, 500, 300, 200], true, true, true, false], # 33
      [[100, 500, 300, 200, 400], [100, 500, 300, 200], true, true, false, false], # 34
      [[100, 500, 300, 200, 400], [100, 500, 300, 200], true, false, true, false], # 35
      [[100, 500, 300, 200, 400], [100, 500, 300, 200], true, false, false, false], # 36
      [[100, 500, 300, 200, 400], [100, 500, 300, 200], false, true, true, false], # 37
      [[100, 500, 300, 200, 400], [100, 500, 300, 200], false, true, false, false], # 38
      [[100, 500, 300, 200, 400], [100, 500, 300, 200], false, false, true, false], # 39
      [[100, 500, 300, 200, 400], [100, 500, 300, 200], false, false, false, false], # 40

      [[100, 500, 300, 200], [100, 500, 300, 200, 400], true, true, true, false], # 41
      [[100, 500, 300, 200], [100, 500, 300, 200, 400], true, true, false, true], # 42
      [[100, 500, 300, 200], [100, 500, 300, 200, 400], true, false, true, false], # 43
      [[100, 500, 300, 200], [100, 500, 300, 200, 400], true, false, false, true], # 44
      [[100, 500, 300, 200], [100, 500, 300, 200, 400], false, true, true, false], # 45
      [[100, 500, 300, 200], [100, 500, 300, 200, 400], false, true, false, true], # 46
      [[100, 500, 300, 200], [100, 500, 300, 200, 400], false, false, true, false], # 47
      [[100, 500, 300, 200], [100, 500, 300, 200, 400], false, false, false, true], # 48

      [{
         "menu": {
           "id": "file",
           "value": "File",
           "popup": {
             "menuitem": [
               {
                 "value": "New",
                 "onclick": "CreateDoc[]"
               },
               {
                 "value": "Open",
                 "onclick": "OpenDoc[]"
               },
               {
                 "value": "Save",
                 "onclick": "SaveDoc[]"
               }
             ]
           }
         }
       }, 'Not a dictionary', true, true, true, false], # 49
      [{
         "menu": {
           "id": "file",
           "value": "File",
           "popup": {
             "menuitem": [
               {
                 "value": "New",
                 "onclick": "CreateDoc[]"
               },
               {
                 "value": "Open",
                 "onclick": "OpenDoc[]"
               },
               {
                 "value": "Save",
                 "onclick": "SaveDoc[]"
               }
             ]
           }
         }
       }, {
         "menu": {
           "id": "file",
           "value": "File",
           "popup": {
             "menuitem": [
               {
                 "value": "New",
                 "onclick": "CreateDoc[]"
               },
               {
                 "value": "Open",
                 "onclick": "OpenDoc[]"
               },
               {
                 "value": "Save",
                 "onclick": "SaveDoc[]"
               }
             ]
           }
         }
       }, true, true, true, true], # 50
      [{
         "menu": {
           "id": "file",
           "value": "File",
           "popup": {
             "menuitem": [
               {
                 "value": "New",
                 "onclick": "CreateDoc[]"
               },
               {
                 "value": "Open",
                 "onclick": "OpenDoc[]"
               },
               {
                 "value": "Save",
                 "onclick": "SaveDoc[]"
               }
             ]
           }
         }
       }, {
         "menu": {
           "id": "file",
           "value": "File",
           "popup": {
             "menuitem": [
               {
                 "value": "New",
                 "onclick": "CreateDoc[]"
               },
               {
                 "value": "Open",
                 "onclick": "OpenDoc[]"
               },
               {
                 "value": "Save",
                 "onclick": "SaveDoc[]"
               }
             ]
           }
         }
       }, true, true, false, true], # 51
      [{
         "menu": {
           "id": "file",
           "value": "File",
           "popup": {
             "menuitem": [
               {
                 "value": "New",
                 "onclick": "CreateDoc[]"
               },
               {
                 "value": "Open",
                 "onclick": "OpenDoc[]"
               },
               {
                 "value": "Save",
                 "onclick": "SaveDoc[]"
               }
             ]
           }
         }
       }, {
         "menu": {
           "id": "file",
           "value": "File",
           "popup": {
             "menuitem": [
               {
                 "value": "New",
                 "onclick": "CreateDoc[]"
               },
               {
                 "value": "Open",
                 "onclick": "OpenDoc[]"
               },
               {
                 "value": "Save",
                 "onclick": "SaveDoc[]"
               }
             ]
           }
         }
       }, true, false, true, true], # 52
      [{
         "menu": {
           "id": "file",
           "value": "File",
           "popup": {
             "menuitem": [
               {
                 "value": "New",
                 "onclick": "CreateDoc[]"
               },
               {
                 "value": "Open",
                 "onclick": "OpenDoc[]"
               },
               {
                 "value": "Save",
                 "onclick": "SaveDoc[]"
               }
             ]
           }
         }
       }, {
         "menu": {
           "id": "file",
           "value": "File",
           "popup": {
             "menuitem": [
               {
                 "value": "New",
                 "onclick": "CreateDoc[]"
               },
               {
                 "value": "Open",
                 "onclick": "OpenDoc[]"
               },
               {
                 "value": "Save",
                 "onclick": "SaveDoc[]"
               }
             ]
           }
         }
       }, true, false, false, true], # 53
      [{
         "menu": {
           "id": "file",
           "value": "File",
           "popup": {
             "menuitem": [
               {
                 "value": "New",
                 "onclick": "CreateDoc[]"
               },
               {
                 "value": "Open",
                 "onclick": "OpenDoc[]"
               },
               {
                 "value": "Save",
                 "onclick": "SaveDoc[]"
               }
             ]
           }
         }
       }, {
         "menu": {
           "id": "file",
           "value": "File",
           "popup": {
             "menuitem": [
               {
                 "value": "New",
                 "onclick": "CreateDoc[]"
               },
               {
                 "value": "Open",
                 "onclick": "OpenDoc[]"
               },
               {
                 "value": "Save",
                 "onclick": "SaveDoc[]"
               }
             ]
           }
         }
       }, false, true, true, true], # 54
      [{
         "menu": {
           "id": "file",
           "value": "File",
           "popup": {
             "menuitem": [
               {
                 "value": "New",
                 "onclick": "CreateDoc[]"
               },
               {
                 "value": "Open",
                 "onclick": "OpenDoc[]"
               },
               {
                 "value": "Save",
                 "onclick": "SaveDoc[]"
               }
             ]
           }
         }
       }, {
         "menu": {
           "id": "file",
           "value": "File",
           "popup": {
             "menuitem": [
               {
                 "value": "New",
                 "onclick": "CreateDoc[]"
               },
               {
                 "value": "Open",
                 "onclick": "OpenDoc[]"
               },
               {
                 "value": "Save",
                 "onclick": "SaveDoc[]"
               }
             ]
           }
         }
       }, false, true, false, true], # 55
      [{
         "menu": {
           "id": "file",
           "value": "File",
           "popup": {
             "menuitem": [
               {
                 "value": "New",
                 "onclick": "CreateDoc[]"
               },
               {
                 "value": "Open",
                 "onclick": "OpenDoc[]"
               },
               {
                 "value": "Save",
                 "onclick": "SaveDoc[]"
               }
             ]
           }
         }
       }, {
         "menu": {
           "id": "file",
           "value": "File",
           "popup": {
             "menuitem": [
               {
                 "value": "New",
                 "onclick": "CreateDoc[]"
               },
               {
                 "value": "Open",
                 "onclick": "OpenDoc[]"
               },
               {
                 "value": "Save",
                 "onclick": "SaveDoc[]"
               }
             ]
           }
         }
       }, false, false, true, true], # 56
      [{
         "menu": {
           "id": "file",
           "value": "File",
           "popup": {
             "menuitem": [
               {
                 "value": "New",
                 "onclick": "CreateDoc[]"
               },
               {
                 "value": "Open",
                 "onclick": "OpenDoc[]"
               },
               {
                 "value": "Save",
                 "onclick": "SaveDoc[]"
               }
             ]
           }
         }
       }, {
         "menu": {
           "id": "file",
           "value": "File",
           "popup": {
             "menuitem": [
               {
                 "value": "New",
                 "onclick": "CreateDoc[]"
               },
               {
                 "value": "Open",
                 "onclick": "OpenDoc[]"
               },
               {
                 "value": "Save",
                 "onclick": "SaveDoc[]"
               }
             ]
           }
         }
       }, false, false, false, true], # 57

      [{
         "menu": {
           "changed-id": "file",
           "changed-value": "File",
           "changed-popup": {
             "changed-menuitem": [
               {
                 "changed-value": "New",
                 "changed-onclick": "CreateDoc[]"
               },
               {
                 "changed-value": "Open",
                 "changed-onclick": "OpenDoc[]"
               },
               {
                 "changed-value": "Save",
                 "changed-onclick": "SaveDoc[]"
               }
             ]
           }
         }
       }, {
         "menu": {
           "id": "file",
           "value": "File",
           "popup": {
             "menuitem": [
               {
                 "value": "New",
                 "onclick": "CreateDoc[]"
               },
               {
                 "value": "Open",
                 "onclick": "OpenDoc[]"
               },
               {
                 "value": "Save",
                 "onclick": "SaveDoc[]"
               }
             ]
           }
         }
       }, true, true, true, false], # 58
      [{
         "menu": {
           "changed-id": "file",
           "changed-value": "File",
           "changed-popup": {
             "changed-menuitem": [
               {
                 "changed-value": "New",
                 "changed-onclick": "CreateDoc[]"
               },
               {
                 "changed-value": "Open",
                 "changed-onclick": "OpenDoc[]"
               },
               {
                 "changed-value": "Save",
                 "changed-onclick": "SaveDoc[]"
               }
             ]
           }
         }
       }, {
         "menu": {
           "id": "file",
           "value": "File",
           "popup": {
             "menuitem": [
               {
                 "value": "New",
                 "onclick": "CreateDoc[]"
               },
               {
                 "value": "Open",
                 "onclick": "OpenDoc[]"
               },
               {
                 "value": "Save",
                 "onclick": "SaveDoc[]"
               }
             ]
           }
         }
       }, true, true, false, false], # 59
      [{
         "menu": {
           "changed-id": "file",
           "changed-value": "File",
           "changed-popup": {
             "changed-menuitem": [
               {
                 "changed-value": "New",
                 "changed-onclick": "CreateDoc[]"
               },
               {
                 "changed-value": "Open",
                 "changed-onclick": "OpenDoc[]"
               },
               {
                 "changed-value": "Save",
                 "changed-onclick": "SaveDoc[]"
               }
             ]
           }
         }
       }, {
         "menu": {
           "id": "file",
           "value": "File",
           "popup": {
             "menuitem": [
               {
                 "value": "New",
                 "onclick": "CreateDoc[]"
               },
               {
                 "value": "Open",
                 "onclick": "OpenDoc[]"
               },
               {
                 "value": "Save",
                 "onclick": "SaveDoc[]"
               }
             ]
           }
         }
       }, true, false, true, false], # 60
      [{
         "menu": {
           "changed-id": "file",
           "changed-value": "File",
           "changed-popup": {
             "changed-menuitem": [
               {
                 "changed-value": "New",
                 "changed-onclick": "CreateDoc[]"
               },
               {
                 "changed-value": "Open",
                 "changed-onclick": "OpenDoc[]"
               },
               {
                 "changed-value": "Save",
                 "changed-onclick": "SaveDoc[]"
               }
             ]
           }
         }
       }, {
         "menu": {
           "id": "file",
           "value": "File",
           "popup": {
             "menuitem": [
               {
                 "value": "New",
                 "onclick": "CreateDoc[]"
               },
               {
                 "value": "Open",
                 "onclick": "OpenDoc[]"
               },
               {
                 "value": "Save",
                 "onclick": "SaveDoc[]"
               }
             ]
           }
         }
       }, true, false, false, false], # 61
      [{
         "menu": {
           "changed-id": "file",
           "changed-value": "File",
           "changed-popup": {
             "changed-menuitem": [
               {
                 "changed-value": "New",
                 "changed-onclick": "CreateDoc[]"
               },
               {
                 "changed-value": "Open",
                 "changed-onclick": "OpenDoc[]"
               },
               {
                 "changed-value": "Save",
                 "changed-onclick": "SaveDoc[]"
               }
             ]
           }
         }
       }, {
         "menu": {
           "id": "file",
           "value": "File",
           "popup": {
             "menuitem": [
               {
                 "value": "New",
                 "onclick": "CreateDoc[]"
               },
               {
                 "value": "Open",
                 "onclick": "OpenDoc[]"
               },
               {
                 "value": "Save",
                 "onclick": "SaveDoc[]"
               }
             ]
           }
         }
       }, false, true, true, false], # 62
      [{
         "menu": {
           "changed-id": "file",
           "changed-value": "File",
           "changed-popup": {
             "changed-menuitem": [
               {
                 "changed-value": "New",
                 "changed-onclick": "CreateDoc[]"
               },
               {
                 "changed-value": "Open",
                 "changed-onclick": "OpenDoc[]"
               },
               {
                 "changed-value": "Save",
                 "changed-onclick": "SaveDoc[]"
               }
             ]
           }
         }
       }, {
         "menu": {
           "id": "file",
           "value": "File",
           "popup": {
             "menuitem": [
               {
                 "value": "New",
                 "onclick": "CreateDoc[]"
               },
               {
                 "value": "Open",
                 "onclick": "OpenDoc[]"
               },
               {
                 "value": "Save",
                 "onclick": "SaveDoc[]"
               }
             ]
           }
         }
       }, false, true, false, false], # 63
      [{
         "menu": {
           "changed-id": "file",
           "changed-value": "File",
           "changed-popup": {
             "changed-menuitem": [
               {
                 "changed-value": "New",
                 "changed-onclick": "CreateDoc[]"
               },
               {
                 "changed-value": "Open",
                 "changed-onclick": "OpenDoc[]"
               },
               {
                 "changed-value": "Save",
                 "changed-onclick": "SaveDoc[]"
               }
             ]
           }
         }
       }, {
         "menu": {
           "id": "file",
           "value": "File",
           "popup": {
             "menuitem": [
               {
                 "value": "New",
                 "onclick": "CreateDoc[]"
               },
               {
                 "value": "Open",
                 "onclick": "OpenDoc[]"
               },
               {
                 "value": "Save",
                 "onclick": "SaveDoc[]"
               }
             ]
           }
         }
       }, false, false, true, false], # 64
      [{
         "menu": {
           "changed-id": "file",
           "changed-value": "File",
           "changed-popup": {
             "changed-menuitem": [
               {
                 "changed-value": "New",
                 "changed-onclick": "CreateDoc[]"
               },
               {
                 "changed-value": "Open",
                 "changed-onclick": "OpenDoc[]"
               },
               {
                 "changed-value": "Save",
                 "changed-onclick": "SaveDoc[]"
               }
             ]
           }
         }
       }, {
         "menu": {
           "id": "file",
           "value": "File",
           "popup": {
             "menuitem": [
               {
                 "value": "New",
                 "onclick": "CreateDoc[]"
               },
               {
                 "value": "Open",
                 "onclick": "OpenDoc[]"
               },
               {
                 "value": "Save",
                 "onclick": "SaveDoc[]"
               }
             ]
           }
         }
       }, false, false, false, false], # 65

      [{
         "menu": {
           "id": "file",
           "value": "File",
           "popup": {
             "menuitem": [
               {
                 "value": "New",
                 "onclick": "CreateDoc[]"
               },
               {
                 "value": "Open",
                 "onclick": "OpenDoc[]"
               },
               {
                 "value": "Save",
                 "onclick": "SaveDoc[]"
               }
             ]
           }
         }
       }, {
         "menu": {
           "changed-id": "file",
           "changed-value": "File",
           "changed-popup": {
             "changed-menuitem": [
               {
                 "changed-value": "New",
                 "changed-onclick": "CreateDoc[]"
               },
               {
                 "changed-value": "Open",
                 "changed-onclick": "OpenDoc[]"
               },
               {
                 "changed-value": "Save",
                 "changed-onclick": "SaveDoc[]"
               }
             ]
           }
         }
       }, true, true, true, false], # 66
      [{
         "menu": {
           "id": "file",
           "value": "File",
           "popup": {
             "menuitem": [
               {
                 "value": "New",
                 "onclick": "CreateDoc[]"
               },
               {
                 "value": "Open",
                 "onclick": "OpenDoc[]"
               },
               {
                 "value": "Save",
                 "onclick": "SaveDoc[]"
               }
             ]
           }
         }
       }, {
         "menu": {
           "changed-id": "file",
           "changed-value": "File",
           "changed-popup": {
             "changed-menuitem": [
               {
                 "changed-value": "New",
                 "changed-onclick": "CreateDoc[]"
               },
               {
                 "changed-value": "Open",
                 "changed-onclick": "OpenDoc[]"
               },
               {
                 "changed-value": "Save",
                 "changed-onclick": "SaveDoc[]"
               }
             ]
           }
         }
       }, true, true, false, false], # 67
      [{
         "menu": {
           "id": "file",
           "value": "File",
           "popup": {
             "menuitem": [
               {
                 "value": "New",
                 "onclick": "CreateDoc[]"
               },
               {
                 "value": "Open",
                 "onclick": "OpenDoc[]"
               },
               {
                 "value": "Save",
                 "onclick": "SaveDoc[]"
               }
             ]
           }
         }
       }, {
         "menu": {
           "changed-id": "file",
           "changed-value": "File",
           "changed-popup": {
             "changed-menuitem": [
               {
                 "changed-value": "New",
                 "changed-onclick": "CreateDoc[]"
               },
               {
                 "changed-value": "Open",
                 "changed-onclick": "OpenDoc[]"
               },
               {
                 "changed-value": "Save",
                 "changed-onclick": "SaveDoc[]"
               }
             ]
           }
         }
       }, true, false, true, false], # 68
      [{
         "menu": {
           "id": "file",
           "value": "File",
           "popup": {
             "menuitem": [
               {
                 "value": "New",
                 "onclick": "CreateDoc[]"
               },
               {
                 "value": "Open",
                 "onclick": "OpenDoc[]"
               },
               {
                 "value": "Save",
                 "onclick": "SaveDoc[]"
               }
             ]
           }
         }
       }, {
         "menu": {
           "changed-id": "file",
           "changed-value": "File",
           "changed-popup": {
             "changed-menuitem": [
               {
                 "changed-value": "New",
                 "changed-onclick": "CreateDoc[]"
               },
               {
                 "changed-value": "Open",
                 "changed-onclick": "OpenDoc[]"
               },
               {
                 "changed-value": "Save",
                 "changed-onclick": "SaveDoc[]"
               }
             ]
           }
         }
       }, true, false, false, false], # 69
      [{
         "menu": {
           "id": "file",
           "value": "File",
           "popup": {
             "menuitem": [
               {
                 "value": "New",
                 "onclick": "CreateDoc[]"
               },
               {
                 "value": "Open",
                 "onclick": "OpenDoc[]"
               },
               {
                 "value": "Save",
                 "onclick": "SaveDoc[]"
               }
             ]
           }
         }
       }, {
         "menu": {
           "changed-id": "file",
           "changed-value": "File",
           "changed-popup": {
             "changed-menuitem": [
               {
                 "changed-value": "New",
                 "changed-onclick": "CreateDoc[]"
               },
               {
                 "changed-value": "Open",
                 "changed-onclick": "OpenDoc[]"
               },
               {
                 "changed-value": "Save",
                 "changed-onclick": "SaveDoc[]"
               }
             ]
           }
         }
       }, false, true, true, false], # 70
      [{
         "menu": {
           "id": "file",
           "value": "File",
           "popup": {
             "menuitem": [
               {
                 "value": "New",
                 "onclick": "CreateDoc[]"
               },
               {
                 "value": "Open",
                 "onclick": "OpenDoc[]"
               },
               {
                 "value": "Save",
                 "onclick": "SaveDoc[]"
               }
             ]
           }
         }
       }, {
         "menu": {
           "changed-id": "file",
           "changed-value": "File",
           "changed-popup": {
             "changed-menuitem": [
               {
                 "changed-value": "New",
                 "changed-onclick": "CreateDoc[]"
               },
               {
                 "changed-value": "Open",
                 "changed-onclick": "OpenDoc[]"
               },
               {
                 "changed-value": "Save",
                 "changed-onclick": "SaveDoc[]"
               }
             ]
           }
         }
       }, false, true, false, false], # 71
      [{
         "menu": {
           "id": "file",
           "value": "File",
           "popup": {
             "menuitem": [
               {
                 "value": "New",
                 "onclick": "CreateDoc[]"
               },
               {
                 "value": "Open",
                 "onclick": "OpenDoc[]"
               },
               {
                 "value": "Save",
                 "onclick": "SaveDoc[]"
               }
             ]
           }
         }
       }, {
         "menu": {
           "changed-id": "file",
           "changed-value": "File",
           "changed-popup": {
             "changed-menuitem": [
               {
                 "changed-value": "New",
                 "changed-onclick": "CreateDoc[]"
               },
               {
                 "changed-value": "Open",
                 "changed-onclick": "OpenDoc[]"
               },
               {
                 "changed-value": "Save",
                 "changed-onclick": "SaveDoc[]"
               }
             ]
           }
         }
       }, false, false, true, false], # 72
      [{
         "menu": {
           "id": "file",
           "value": "File",
           "popup": {
             "menuitem": [
               {
                 "value": "New",
                 "onclick": "CreateDoc[]"
               },
               {
                 "value": "Open",
                 "onclick": "OpenDoc[]"
               },
               {
                 "value": "Save",
                 "onclick": "SaveDoc[]"
               }
             ]
           }
         }
       }, {
         "menu": {
           "changed-id": "file",
           "changed-value": "File",
           "changed-popup": {
             "changed-menuitem": [
               {
                 "changed-value": "New",
                 "changed-onclick": "CreateDoc[]"
               },
               {
                 "changed-value": "Open",
                 "changed-onclick": "OpenDoc[]"
               },
               {
                 "changed-value": "Save",
                 "changed-onclick": "SaveDoc[]"
               }
             ]
           }
         }
       }, false, false, false, false], # 73

      [{
         "menu": {
           "id": "file",
           "value": "File",
           "popup": {
             "menuitem": [
               {
                 "value": "New",
                 "onclick": "CreateDoc[]"
               },
               {
                 "value": "Open",
                 "onclick": "OpenDoc[]"
               },
               {
                 "value": "Save",
                 "onclick": "SaveDoc[]"
               }
             ]
           }
         }
       }, {
         "menu": {
           "value": "File",
           "id": "file",
           "popup": {
             "menuitem": [
               {
                 "value": "New",
                 "onclick": "CreateDoc[]"
               },
               {
                 "value": "Open",
                 "onclick": "OpenDoc[]"
               },
               {
                 "value": "Save",
                 "onclick": "SaveDoc[]"
               }
             ]
           }
         }
       }, true, true, true, true], # 74 [suspicious]
      [{
         "menu": {
           "id": "file",
           "value": "File",
           "popup": {
             "menuitem": [
               {
                 "value": "New",
                 "onclick": "CreateDoc[]"
               },
               {
                 "value": "Open",
                 "onclick": "OpenDoc[]"
               },
               {
                 "value": "Save",
                 "onclick": "SaveDoc[]"
               }
             ]
           }
         }
       }, {
         "menu": {
           "value": "File",
           "id": "file",
           "popup": {
             "menuitem": [
               {
                 "value": "New",
                 "onclick": "CreateDoc[]"
               },
               {
                 "value": "Open",
                 "onclick": "OpenDoc[]"
               },
               {
                 "value": "Save",
                 "onclick": "SaveDoc[]"
               }
             ]
           }
         }
       }, true, true, false, true], # 75 [suspicious]
      [{
         "menu": {
           "id": "file",
           "value": "File",
           "popup": {
             "menuitem": [
               {
                 "value": "New",
                 "onclick": "CreateDoc[]"
               },
               {
                 "value": "Open",
                 "onclick": "OpenDoc[]"
               },
               {
                 "value": "Save",
                 "onclick": "SaveDoc[]"
               }
             ]
           }
         }
       }, {
         "menu": {
           "value": "File",
           "id": "file",
           "popup": {
             "menuitem": [
               {
                 "value": "New",
                 "onclick": "CreateDoc[]"
               },
               {
                 "value": "Open",
                 "onclick": "OpenDoc[]"
               },
               {
                 "value": "Save",
                 "onclick": "SaveDoc[]"
               }
             ]
           }
         }
       }, true, false, true, true], # 76
      [{
         "menu": {
           "id": "file",
           "value": "File",
           "popup": {
             "menuitem": [
               {
                 "value": "New",
                 "onclick": "CreateDoc[]"
               },
               {
                 "value": "Open",
                 "onclick": "OpenDoc[]"
               },
               {
                 "value": "Save",
                 "onclick": "SaveDoc[]"
               }
             ]
           }
         }
       }, {
         "menu": {
           "value": "File",
           "id": "file",
           "popup": {
             "menuitem": [
               {
                 "value": "New",
                 "onclick": "CreateDoc[]"
               },
               {
                 "value": "Open",
                 "onclick": "OpenDoc[]"
               },
               {
                 "value": "Save",
                 "onclick": "SaveDoc[]"
               }
             ]
           }
         }
       }, true, false, false, true], # 77
      [{
         "menu": {
           "id": "file",
           "value": "File",
           "popup": {
             "menuitem": [
               {
                 "value": "New",
                 "onclick": "CreateDoc[]"
               },
               {
                 "value": "Open",
                 "onclick": "OpenDoc[]"
               },
               {
                 "value": "Save",
                 "onclick": "SaveDoc[]"
               }
             ]
           }
         }
       }, {
         "menu": {
           "value": "File",
           "id": "file",
           "popup": {
             "menuitem": [
               {
                 "value": "New",
                 "onclick": "CreateDoc[]"
               },
               {
                 "value": "Open",
                 "onclick": "OpenDoc[]"
               },
               {
                 "value": "Save",
                 "onclick": "SaveDoc[]"
               }
             ]
           }
         }
       }, false, true, true, true], # 78 [suspicious]
      [{
         "menu": {
           "id": "file",
           "value": "File",
           "popup": {
             "menuitem": [
               {
                 "value": "New",
                 "onclick": "CreateDoc[]"
               },
               {
                 "value": "Open",
                 "onclick": "OpenDoc[]"
               },
               {
                 "value": "Save",
                 "onclick": "SaveDoc[]"
               }
             ]
           }
         }
       }, {
         "menu": {
           "value": "File",
           "id": "file",
           "popup": {
             "menuitem": [
               {
                 "value": "New",
                 "onclick": "CreateDoc[]"
               },
               {
                 "value": "Open",
                 "onclick": "OpenDoc[]"
               },
               {
                 "value": "Save",
                 "onclick": "SaveDoc[]"
               }
             ]
           }
         }
       }, false, true, false, true], # 79 [suspicious]
      [{
         "menu": {
           "id": "file",
           "value": "File",
           "popup": {
             "menuitem": [
               {
                 "value": "New",
                 "onclick": "CreateDoc[]"
               },
               {
                 "value": "Open",
                 "onclick": "OpenDoc[]"
               },
               {
                 "value": "Save",
                 "onclick": "SaveDoc[]"
               }
             ]
           }
         }
       }, {
         "menu": {
           "value": "File",
           "id": "file",
           "popup": {
             "menuitem": [
               {
                 "value": "New",
                 "onclick": "CreateDoc[]"
               },
               {
                 "value": "Open",
                 "onclick": "OpenDoc[]"
               },
               {
                 "value": "Save",
                 "onclick": "SaveDoc[]"
               }
             ]
           }
         }
       }, false, false, true, true], # 80
      [{
         "menu": {
           "id": "file",
           "value": "File",
           "popup": {
             "menuitem": [
               {
                 "value": "New",
                 "onclick": "CreateDoc[]"
               },
               {
                 "value": "Open",
                 "onclick": "OpenDoc[]"
               },
               {
                 "value": "Save",
                 "onclick": "SaveDoc[]"
               }
             ]
           }
         }
       }, {
         "menu": {
           "value": "File",
           "id": "file",
           "popup": {
             "menuitem": [
               {
                 "value": "New",
                 "onclick": "CreateDoc[]"
               },
               {
                 "value": "Open",
                 "onclick": "OpenDoc[]"
               },
               {
                 "value": "Save",
                 "onclick": "SaveDoc[]"
               }
             ]
           }
         }
       }, false, false, false, true], # 81

      [{
         "menu": {
           "id": "file",
           "value": "File",
           "popup": {
             "menuitem": [
               {
                 "value": "New",
                 "onclick": "CreateDoc[]"
               },
               {
                 "value": "Open",
                 "onclick": "OpenDoc[]"
               },
               {
                 "value": "Save",
                 "onclick": "SaveDoc[]"
               }
             ]
           }
         }
       }, {
         "menu": {
           "value": "File",
           "id": "file",
           "popup": {
             "menuitem": [
               {
                 "value": "New",
                 "onclick": "CreateDoc[]"
               },
               {
                 "value": "Open",
                 "onclick": "OpenDoc[]"
               }
             ]
           }
         }
       }, true, true, true, false], # 82
      [{
         "menu": {
           "id": "file",
           "value": "File",
           "popup": {
             "menuitem": [
               {
                 "value": "New",
                 "onclick": "CreateDoc[]"
               },
               {
                 "value": "Open",
                 "onclick": "OpenDoc[]"
               },
               {
                 "value": "Save",
                 "onclick": "SaveDoc[]"
               }
             ]
           }
         }
       }, {
         "menu": {
           "value": "File",
           "id": "file",
           "popup": {
             "menuitem": [
               {
                 "value": "New",
                 "onclick": "CreateDoc[]"
               },
               {
                 "value": "Open",
                 "onclick": "OpenDoc[]"
               }
             ]
           }
         }
       }, true, true, false, false], # 83
      [{
         "menu": {
           "id": "file",
           "value": "File",
           "popup": {
             "menuitem": [
               {
                 "value": "New",
                 "onclick": "CreateDoc[]"
               },
               {
                 "value": "Open",
                 "onclick": "OpenDoc[]"
               },
               {
                 "value": "Save",
                 "onclick": "SaveDoc[]"
               }
             ]
           }
         }
       }, {
         "menu": {
           "value": "File",
           "id": "file",
           "popup": {
             "menuitem": [
               {
                 "value": "New",
                 "onclick": "CreateDoc[]"
               },
               {
                 "value": "Open",
                 "onclick": "OpenDoc[]"
               }
             ]
           }
         }
       }, true, false, true, false], # 84
      [{
         "menu": {
           "id": "file",
           "value": "File",
           "popup": {
             "menuitem": [
               {
                 "value": "New",
                 "onclick": "CreateDoc[]"
               },
               {
                 "value": "Open",
                 "onclick": "OpenDoc[]"
               },
               {
                 "value": "Save",
                 "onclick": "SaveDoc[]"
               }
             ]
           }
         }
       }, {
         "menu": {
           "value": "File",
           "id": "file",
           "popup": {
             "menuitem": [
               {
                 "value": "New",
                 "onclick": "CreateDoc[]"
               },
               {
                 "value": "Open",
                 "onclick": "OpenDoc[]"
               }
             ]
           }
         }
       }, true, false, false, false], # 85
      [{
         "menu": {
           "id": "file",
           "value": "File",
           "popup": {
             "menuitem": [
               {
                 "value": "New",
                 "onclick": "CreateDoc[]"
               },
               {
                 "value": "Open",
                 "onclick": "OpenDoc[]"
               },
               {
                 "value": "Save",
                 "onclick": "SaveDoc[]"
               }
             ]
           }
         }
       }, {
         "menu": {
           "value": "File",
           "id": "file",
           "popup": {
             "menuitem": [
               {
                 "value": "New",
                 "onclick": "CreateDoc[]"
               },
               {
                 "value": "Open",
                 "onclick": "OpenDoc[]"
               }
             ]
           }
         }
       }, false, true, true, true], # 86 [suspicious]
      [{
         "menu": {
           "id": "file",
           "value": "File",
           "popup": {
             "menuitem": [
               {
                 "value": "New",
                 "onclick": "CreateDoc[]"
               },
               {
                 "value": "Open",
                 "onclick": "OpenDoc[]"
               },
               {
                 "value": "Save",
                 "onclick": "SaveDoc[]"
               }
             ]
           }
         }
       }, {
         "menu": {
           "value": "File",
           "id": "file",
           "popup": {
             "menuitem": [
               {
                 "value": "New",
                 "onclick": "CreateDoc[]"
               },
               {
                 "value": "Open",
                 "onclick": "OpenDoc[]"
               }
             ]
           }
         }
       }, false, true, false, true], # 87 [suspicious]
      [{
         "menu": {
           "id": "file",
           "value": "File",
           "popup": {
             "menuitem": [
               {
                 "value": "New",
                 "onclick": "CreateDoc[]"
               },
               {
                 "value": "Open",
                 "onclick": "OpenDoc[]"
               },
               {
                 "value": "Save",
                 "onclick": "SaveDoc[]"
               }
             ]
           }
         }
       }, {
         "menu": {
           "value": "File",
           "id": "file",
           "popup": {
             "menuitem": [
               {
                 "value": "New",
                 "onclick": "CreateDoc[]"
               },
               {
                 "value": "Open",
                 "onclick": "OpenDoc[]"
               }
             ]
           }
         }
       }, false, false, true, true], # 88 [suspicious]
      [{
         "menu": {
           "id": "file",
           "value": "File",
           "popup": {
             "menuitem": [
               {
                 "value": "New",
                 "onclick": "CreateDoc[]"
               },
               {
                 "value": "Open",
                 "onclick": "OpenDoc[]"
               },
               {
                 "value": "Save",
                 "onclick": "SaveDoc[]"
               }
             ]
           }
         }
       }, {
         "menu": {
           "value": "File",
           "id": "file",
           "popup": {
             "menuitem": [
               {
                 "value": "New",
                 "onclick": "CreateDoc[]"
               },
               {
                 "value": "Open",
                 "onclick": "OpenDoc[]"
               }
             ]
           }
         }
       }, false, false, false, true], # 89 [suspicious]

      [{
         "menu": {
           "value": "File",
           "id": "file",
           "popup": {
             "menuitem": [
               {
                 "value": "New",
                 "onclick": "CreateDoc[]"
               },
               {
                 "value": "Open",
                 "onclick": "OpenDoc[]"
               }
             ]
           }
         }
       }, {
         "menu": {
           "id": "file",
           "value": "File",
           "popup": {
             "menuitem": [
               {
                 "value": "New",
                 "onclick": "CreateDoc[]"
               },
               {
                 "value": "Open",
                 "onclick": "OpenDoc[]"
               },
               {
                 "value": "Save",
                 "onclick": "SaveDoc[]"
               }
             ]
           }
         }
       }, true, true, true, false], # 90
      [{
         "menu": {
           "value": "File",
           "id": "file",
           "popup": {
             "menuitem": [
               {
                 "value": "New",
                 "onclick": "CreateDoc[]"
               },
               {
                 "value": "Open",
                 "onclick": "OpenDoc[]"
               }
             ]
           }
         }
       }, {
         "menu": {
           "id": "file",
           "value": "File",
           "popup": {
             "menuitem": [
               {
                 "value": "New",
                 "onclick": "CreateDoc[]"
               },
               {
                 "value": "Open",
                 "onclick": "OpenDoc[]"
               },
               {
                 "value": "Save",
                 "onclick": "SaveDoc[]"
               }
             ]
           }
         }
       }, true, true, false, true], # 91
      [{
         "menu": {
           "value": "File",
           "id": "file",
           "popup": {
             "menuitem": [
               {
                 "value": "New",
                 "onclick": "CreateDoc[]"
               },
               {
                 "value": "Open",
                 "onclick": "OpenDoc[]"
               }
             ]
           }
         }
       }, {
         "menu": {
           "id": "file",
           "value": "File",
           "popup": {
             "menuitem": [
               {
                 "value": "New",
                 "onclick": "CreateDoc[]"
               },
               {
                 "value": "Open",
                 "onclick": "OpenDoc[]"
               },
               {
                 "value": "Save",
                 "onclick": "SaveDoc[]"
               }
             ]
           }
         }
       }, true, false, true, false], # 92
      [{
         "menu": {
           "value": "File",
           "id": "file",
           "popup": {
             "menuitem": [
               {
                 "value": "New",
                 "onclick": "CreateDoc[]"
               },
               {
                 "value": "Open",
                 "onclick": "OpenDoc[]"
               }
             ]
           }
         }
       }, {
         "menu": {
           "id": "file",
           "value": "File",
           "popup": {
             "menuitem": [
               {
                 "value": "New",
                 "onclick": "CreateDoc[]"
               },
               {
                 "value": "Open",
                 "onclick": "OpenDoc[]"
               },
               {
                 "value": "Save",
                 "onclick": "SaveDoc[]"
               }
             ]
           }
         }
       }, true, false, false, true], # 93
      [{
         "menu": {
           "value": "File",
           "id": "file",
           "popup": {
             "menuitem": [
               {
                 "value": "New",
                 "onclick": "CreateDoc[]"
               },
               {
                 "value": "Open",
                 "onclick": "OpenDoc[]"
               }
             ]
           }
         }
       }, {
         "menu": {
           "id": "file",
           "value": "File",
           "popup": {
             "menuitem": [
               {
                 "value": "New",
                 "onclick": "CreateDoc[]"
               },
               {
                 "value": "Open",
                 "onclick": "OpenDoc[]"
               },
               {
                 "value": "Save",
                 "onclick": "SaveDoc[]"
               }
             ]
           }
         }
       }, false, true, true, true], # 94 [suspicious]
      [{
         "menu": {
           "value": "File",
           "id": "file",
           "popup": {
             "menuitem": [
               {
                 "value": "New",
                 "onclick": "CreateDoc[]"
               },
               {
                 "value": "Open",
                 "onclick": "OpenDoc[]"
               }
             ]
           }
         }
       }, {
         "menu": {
           "id": "file",
           "value": "File",
           "popup": {
             "menuitem": [
               {
                 "value": "New",
                 "onclick": "CreateDoc[]"
               },
               {
                 "value": "Open",
                 "onclick": "OpenDoc[]"
               },
               {
                 "value": "Save",
                 "onclick": "SaveDoc[]"
               }
             ]
           }
         }
       }, false, true, false, true], # 95
      [{
         "menu": {
           "value": "File",
           "id": "file",
           "popup": {
             "menuitem": [
               {
                 "value": "New",
                 "onclick": "CreateDoc[]"
               },
               {
                 "value": "Open",
                 "onclick": "OpenDoc[]"
               }
             ]
           }
         }
       }, {
         "menu": {
           "id": "file",
           "value": "File",
           "popup": {
             "menuitem": [
               {
                 "value": "New",
                 "onclick": "CreateDoc[]"
               },
               {
                 "value": "Open",
                 "onclick": "OpenDoc[]"
               },
               {
                 "value": "Save",
                 "onclick": "SaveDoc[]"
               }
             ]
           }
         }
       }, false, false, true, true], # 96 [suspicious]
      [{
         "menu": {
           "value": "File",
           "id": "file",
           "popup": {
             "menuitem": [
               {
                 "value": "New",
                 "onclick": "CreateDoc[]"
               },
               {
                 "value": "Open",
                 "onclick": "OpenDoc[]"
               }
             ]
           }
         }
       }, {
         "menu": {
           "id": "file",
           "value": "File",
           "popup": {
             "menuitem": [
               {
                 "value": "New",
                 "onclick": "CreateDoc[]"
               },
               {
                 "value": "Open",
                 "onclick": "OpenDoc[]"
               },
               {
                 "value": "Save",
                 "onclick": "SaveDoc[]"
               }
             ]
           }
         }
       }, false, false, false, true] # 97
    ]

    test_cases.each do |arr|
      expected_body = arr[0]
      received_body = arr[1]
      check_values = arr[2]
      check_order = arr[3]
      check_count = arr[4]
      expected_output = arr[5]

      match_body_output = ComparisonHelper.match_body(expected_body, received_body, check_values: check_values, check_order: check_order, check_count: check_count)

      assert(match_body_output == expected_output)
    end
  end
end
