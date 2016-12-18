class SplitStoredProcedure < ActiveRecord::Migration
  def up
      execute <<-__EOI
              create PROCEDURE Split(
                  fullstr  varchar(4000),
                  delim VARCHAR(12))
                     BEGIN
                        DECLARE a INT Default 0 ;
                        DECLARE str VARCHAR(255);
                        truncate TABLE Tempsplitvalues;
                        simple_loop: LOOP
                           SET a=a+1;
                           #print a;
                           call SPLIT_STR(fullstr,delim,a, str);
                           #SET str=SPLIT_STR(fullstr,delim,a);
                           #print str;
                           #IF (str is null or str='') THEN
                           IF (str='') THEN
                              LEAVE simple_loop;
                           END IF;
                           
                           
                           insert into Tempsplitvalues (item) values (str);
                     END LOOP simple_loop;
                  END
        __EOI
  end

  def down
    execute <<-__EOI
      DROP PROCEDURE IF EXISTS `Split`;
    __EOI
  end
  
end
