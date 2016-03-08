function [maxValues maxValueIndices] = maxN(list, n)
    [sortedX,sortingIndices] = sort(list,'descend');
    maxValues = sortedX(1:n);
    maxValueIndices = sortingIndices(1:n);
end