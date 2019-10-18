% INPUT:
%   seqs: cell array of sequences
function PlotHistograms( varargin )
    figure; hold on;
    seqs = varargin{1};
    options = varargin(2:end);
    for i = 1: length( seqs )
        % options{:}: expand cell array to comma separated list
        [cnt, edge] = histcounts( seqs{i}, options{:} );
        x = (edge(1:end-1) + edge(2:end)) / 2;
        plot(x, cnt);
    end
end