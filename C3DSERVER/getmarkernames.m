function MarkerNames = getmarkernames(itf)
    MarkerNames = strings;
    nIndex = itf.GetParameterIndex('POINT', 'LABELS');
    nItems = itf.GetParameterLength(nIndex);
    %signalname = upper(signalname);
    %signal_index = -1;

    for i = 1 : nItems,
        target_name = itf.GetParameterValue(nIndex, i-1);
        newstring = target_name(1:min(findstr(target_name, ' '))-1);
        if strmatch(newstring, [], 'exact'), 
            newstring = target_name;
            MarkerNames = [MarkerNames newstring];
        end
%         if strmatch(upper(newstring), signalname, 'exact') == 1,
%             signal_index = i-1;
%         end  
    end
end