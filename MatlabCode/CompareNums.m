function [ Result ] = CompareNums( A,B,test )
% COMPARENUMS
% A function to compare the size of two numbers and return the larger or
% smaller, depending on the value of test statistic,
% 
% INPUTS
% A        Value A
% B        Value B
% test     1 for return largest of A and B, 2 for return smallest, 3 for
%          equality. For tests 1 and 2 if the numbers are the same it returns A.
%
% OUTPUTS
% Result   The larger or smaller if you ran test 1 or 2 or A if they are
%          equal. If you ran test 3 to test equality you get 1 for yes and
%          0 for no.
%
% Sample code [Result]=CompareNums(1,2,1) %To see if 1 or 2 is larger
% H Miller May 2019

%See which test we are doing and provide error if there is a problem
if test==1
   % We are looking to return the largest of A and B
   if A-B<0
       %then B is bigger
       Result=B;
   elseif A-B>0
       Result=A;
   elseif A-B==0
       Result=A;
   else
       disp('Error A and B have different dimensions')
   end
elseif test==2
   % We are looking to return the smallest of A and B
      if A-B<0
       %then B is bigger
       Result=A;
   elseif A-B>0
       Result=B;
   elseif A-B==0
       Result=A;
   else
       disp('Error A and B have different dimensions')
   end
elseif test==3
   disp('Helen you need to write this now')
else
    disp('Error, you are trying to test an unspecified condition')
end
end

