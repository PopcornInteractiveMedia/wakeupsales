class CreateSplitFunction < ActiveRecord::Migration
  def up
     execute <<-__EOI
        CREATE Procedure `SPLIT_STR`(
            x VARCHAR(255),
                  delim VARCHAR(12),
                  pos INT ,
                  out returnvar varchar(255) 
                ) 
                BEGIN
                    set returnvar= REPLACE(SUBSTRING(SUBSTRING_INDEX(x, delim, pos),
                             LENGTH(SUBSTRING_INDEX(x, delim, pos -1)) + 1),
                             delim, '');
                END
       __EOI
  end
  
  
  def down
       execute <<-__EOI
            #DROP FUNCTION IF EXISTS `SPLIT_STR`;
            DROP PROCEDURE IF EXISTS `SPLIT_STR`;
    __EOI
  end
  
end
