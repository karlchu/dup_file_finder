Feature: Find duplicate files

  Scenario: There are no duplicate files
    Given the following files in the directory 'test_data/no_duplicate_files'
      | file_sub_path | content_type | file_size |
      | file1.bin     | random       | 1024      |
      | file2.bin     | random       | 1024      |
    When I execute the duplicate file finder
    Then I should get empty result

  Scenario: There are duplicate files
    Given the following files in the directory 'test_data/duplicate_files'
      | file_sub_path  | content_type | file_size | copy_from |
      | file1.bin      | random       | 1024      |           |
      | file1-copy.bin | copy         |           | file1.bin |
      | file2.bin      | random       | 1024      |           |
    When I execute the duplicate file finder
    Then the result set should contain 1 file-set
    And the file-sets should be as follows
      | file1.bin | file1-copy.bin |
