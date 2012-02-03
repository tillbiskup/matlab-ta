function varargout = xml2struct(docNode)
% XML2STRUCT Convert XML into struct
%
% Usage:
%   struct = xml2struct(docNode);
%
%   docNode - string
%             XML tree, org.apache.xerces.dom.DocumentImpl
%   struct  - struct
%             content of the XML file
%

% (c) 2010, Martin Hussels
% (c) 2010-2012, Till Biskup
% 2012-02-03

% Parse input arguments using the inputParser functionality
parser = inputParser;   % Create an instance of the inputParser class.
parser.FunctionName = mfilename; % Function name included in error messages
parser.KeepUnmatched = true; % Enable errors on unmatched arguments
parser.StructExpand = true; % Enable passing arguments in a structure
parser.addRequired('docNode', @(x)isa(x,'org.apache.xerces.dom.DocumentImpl'));
parser.parse(docNode);
% Do the real stuff
docRootNode=docNode.getDocumentElement;
varname=char(docRootNode.getNodeName);
function normalize(node) % function for removing useless empty textnodes created by the parser
    childnode=node.getFirstChild;
    while ~isempty(childnode)
       if strcmp(char(childnode.getNodeName),'#text')
           if isempty(char(trim(childnode.getTextContent)))
               oldchild=childnode;
               childnode=childnode.getNextSibling;
               node.removeChild(oldchild);
           else
               childnode=childnode.getNextSibling;
           end
       else
           normalize(childnode);
           childnode=childnode.getNextSibling;
       end
    end
end
normalize(docRootNode);
function thiselement=traverse(node)
    switch char(node.getAttribute('class'))
        case 'struct'
            thiselement(eval(node.getAttribute('size')))=struct();
            childnode=node.getFirstChild;
            while ~isempty(childnode)
                name=char(childnode.getNodeName);
                i=str2double(childnode.getAttribute('id'));
                thiselement(i).(name)=traverse(childnode);
                childnode=childnode.getNextSibling;
            end
        case 'cell'
            thiselement=cell(eval(node.getAttribute('size')));
            childnode=node.getFirstChild;
            while ~isempty(childnode)
                i=str2double(childnode.getAttribute('id'));
                thiselement{i}=traverse(childnode);
                childnode=childnode.getNextSibling;
            end
        otherwise
            mclass=char(node.getAttribute('class'));
            msize=eval(node.getAttribute('size'));
            if strcmp(mclass,'char')
                % Bug fix for empty elements that appear as size [1 1] in
                % XML
                if size(char(node.getTextContent))
                    % Bug fix for strings that had originally a trailing
                    % newline character and therefore a size too long by 1
                    try
                        thiselement=...
                            reshape(char(node.getTextContent),msize);
                    catch exception
                        try
                        thiselement=...
                            reshape(char(node.getTextContent),...
                            [msize(1) msize(2)-1]);
                        catch exception2
                            exception = addCause(exception2, exception);
                            throw(exception);
                        end
                    end
                else
                    thiselement = '';
                end
            else
                thiselement=strread(char(node.getTextContent),'%f');
                eval(['thiselement=' mclass '(thiselement);']);
                thiselement=reshape(thiselement,msize);
            end
    end
end
varval=traverse(docRootNode);
if nargout
    varargout{1} = varval;
else
    assignin('caller',varname,varval);
end
end