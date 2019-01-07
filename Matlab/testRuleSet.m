function bool = testRuleSet(ruleset, record)
bool=false;


for r=1:size(ruleset,1)
    
   %get a single rule from the set 
   rule = ruleset{r, 1};
   
   %if all parts of the rule (beacons) are present in the record of
   %interest, then say that this class's context is detected based on the
   %rule
   if all(record(rule))
       bool = true;
       return;
   end
    
end
end