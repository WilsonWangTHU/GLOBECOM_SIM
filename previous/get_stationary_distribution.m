function mu = get_stationary_distribution( p )
% Computes the stationary distribution mu of a Markov chain
% described by p (stochastic matrix, ie sum(p,2)=1).
% Input
% p : transition matrix associated with a policy, p(s,s’)
% Output
% mu : stationary distribution for each state s ( p*mu’=mu’ )
% is_OK_mu : false if p is not a stochatic matrix, else true
s=size(p,1);
mu=zeros(1,s);
if any(abs(sum(p,2)-1)>10^-4) || (size(p,2)~=s)
disp ’ERROR in get_stationary_distribution: argument p must be a stochastic matrix’
else
% mu satisfies p*mu’=mu’ and mu sums to one
A=transpose(p)-eye(s);
A(s,:)=ones(1,s);
b=zeros(s,1);
b(s)=1;
mu=transpose(A\b);
is_OK_mu = ~isempty(mu) && all(mu>-10^-4) && (sum(mu)-1<10^-4);
if ~is_OK_mu; mu=[]; end

end
