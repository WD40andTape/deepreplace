function data = deepreplace(data,match,replacement)
%DEEPREPLACE Find and replace string segments in nested objects.
%   NEWDATA = DEEPREPLACE(DATA,MATCH,REPLACEMENT) replaces all 
%   occurrences of substring(s) MATCH with REPLACEMENT at any level of 
%   the nested object DATA.
%
%   - DATA can be of any class but will only undergo replacement when
%       it contains text, i.e. string array or character vector, at any 
%       hierarchical level.
%   - MATCH must be a text or pattern array. 
%   - REPLACEMENT must be text. It must be the same size as MATCH or be 
%       scalar.
%   - NEWDATA is the same class as DATA. All nonoverlapping occurrences of  
%       each element of MATCH in DATA are replaced by the corresponding 
%       element of REPLACEMENT.
%
%   Examples:
%       DATA = { '2022-12-8', 5; '2022-12-9', 9 };
%       MATCH = [ "-", "2022" ];
%       REPLACEMENT = [ "/", "22" ];
%       deepreplace( DATA, MATCH, REPLACEMENT )
%       % Returns { '22/12/8' , 5; '22/12/9', 9 }.
% 
%       DATA = struct( 'name', 'Jane', 'contact', ...
%           struct('phone', '020 7219 3000', 'mobile', '07911 123456') );
%       DATA(2) = struct( 'name', 'John', 'contact', ...
%           struct('phone', '0303 123 7300', 'mobile', '+44 7975 777666') );
%       MATCH = [ digitsPattern(1) lettersPattern ];
%       REPLACEMENT = '#';
%       deepreplace( DATA, MATCH, REPLACEMENT )
%       % Returns DATA with all digits and words replaced with '#'.
% 
%       For more detailed examples see examples.mlx/examples.pdf.
%    
%   Created in 2022b. Compatible with 2019b and later. Compatible with all 
%   platforms. Please cite George Abrahams 
%   https://github.com/WD40andTape/fieldfun.
% 
%   See also PATTERN, REPLACE, STRREP, REGEXP, REGEXPREP

%   Published under MIT License (see LICENSE.txt).
%   Copyright (c) 2022 George Abrahams.
%   - https://github.com/WD40andTape/
%   - https://www.linkedin.com/in/georgeabrahams/

    arguments
        data
        match {mustBeTextOrPattern}
        replacement {mustBeText,mustBeSameSizeOrScalar(replacement,match)}
    end
    if ~cancontaintext(data)
        return
    end
    % Convert data to cell array class.
    IsInputClass = struct('cell', iscell(data), 'string', ...
        isstring(data), 'char', ischar(data), 'struct', isstruct(data));
    if IsInputClass.string || IsInputClass.char
        data = cellstr(data);
    elseif IsInputClass.struct
        fields = fieldnames(data);
        data = struct2cell(data);
    end
    % Perform replacement on each element, recursively if needed.
    for i=1:numel(data)
        if istext(data{i})
            data{i} = replace(data{i},match,replacement);
        elseif cancontaintext(data{i})
            data{i} = deepreplace(data{i},match,replacement);
        end
    end
    % Convert output class to match input class.
    if IsInputClass.string
        data = string(data);
    elseif IsInputClass.char
        data = char(data);
    elseif IsInputClass.struct
        data = cell2struct(data,fields,1);
    end
end

function mustBeTextOrPattern(a)
    if ~(isa(a,'pattern') || istext(a))
        eidType = 'deepreplace:Validators:NotTextOrPattern';
        msgType = 'Value must be text or a pattern object.';
        throwAsCaller(MException(eidType,msgType))
    end
end
function mustBeSameSizeOrScalar(a,b)
    if ~istextscalar(a) && ~isequal(size(a),size(b))
        eidType = 'deepreplace:Validators:ValuesNotMatching';
        msgType = 'Value must be scalar or the same size.';
        throwAsCaller(MException(eidType,msgType))
    end
end

function tf = istext(text)
    tf = ischar(text) | iscellstr(text) | isstring(text);
end
function tf = istextscalar(text)
    tf = ( ( isstring(text) | iscellstr(text) ) & isscalar(text) ) | ...
        ( ischar(text) & ( isrow(text) | isequal(size(text),[0 0]) ) );
end
function tf = cancontaintext(x)
    tf = iscell(x) | isstruct(x) | isstring(x) | ischar(x);
end