classdef Homography < handle
    methods(Static)
        % See "Decomposition in a projective transformation" in Book 
        % "Multiview Geometry in Computer Vision"
        function [H_s, H_a, H_p] = DecomposeHomographyMatrix(H)
            c = H(1,3);
            f = H(2,3);
            v1 = H(3,1);
            v2 = H(3,2);
            a_ = H(1,1) - c * v1;
            b_ = H(1,2) - c * v2;
            d_ = H(2,1) - f * v1;
            e_ = H(2,2) - f * v2;

            tan_theta = d_ / a_;

            theta = atan( tan_theta);
            r_y = sqrt( (e_ - b_*tan_theta) * tan_theta / (d_ *(1 + tan_theta * tan_theta)) );
            r_x = 1/ r_y;
            p = e_ / r_y / d_ - r_y / tan_theta;
            cos_theta = cos(theta);
            s = a_ * r_y / cos_theta;

            sin_theta = sin(theta);
            H_s = [s*cos_theta -s*sin_theta H(1,3); ...
                   s*sin_theta s*cos_theta  H(2,3); ...
                   0 0 1 ...
                  ];
            H_a = [r_x p 0; ...
                   0 r_y 0; ...
                   0 0 1 ...
                   ];
            H_p = [ 1 0 0; ...
                    0 1 0; ...
                    H(3,1) H(3,2) H(3,3) ...
                    ];
        end
        
        function [xo, yo] = Project(H, x, y)
            one_v = ones(1, length(x));
            in = [x; y; one_v];
            out = H * in;
            xo = out(1,:) ./ out(3,:);
            yo = out(2,:) ./ out(3,:);
        end
    end
end