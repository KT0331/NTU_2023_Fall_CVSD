function [indata ,fid_R ,fid_y] = ReadData(packet_no)

    switch packet_no
            case 1
                indata = textread('.\packet_1\input_H_and_y.dat','%s');
                fid_R = fopen('.\Result\out_R_SNR10_P1_result.txt','wt');
                fid_y = fopen('.\Result\out_y_hat_SNR10_P1_result.txt','wt');
            case 2
                indata = textread('.\packet_2\input_H_and_y.dat','%s');
                fid_R = fopen('.\Result\out_R_SNR10_P2_result.txt','wt');
		        fid_y = fopen('.\Result\out_y_hat_SNR10_P2_result.txt','wt');
            case 3
                indata = textread('.\packet_3\input_H_and_y.dat','%s');
                fid_R = fopen('.\Result\out_R_SNR10_P3_result.txt','wt');
		        fid_y = fopen('.\Result\out_y_hat_SNR10_P3_result.txt','wt');
            case 4
                indata = textread('.\packet_4\input_H_and_y.dat','%s');
                fid_R = fopen('.\Result\out_R_SNR15_P4_result.txt','wt');
		        fid_y = fopen('.\Result\out_y_hat_SNR15_P4_result.txt','wt');
            case 5
                indata = textread('.\packet_5\input_H_and_y.dat','%s');
                fid_R = fopen('.\Result\out_R_SNR15_P5_result.txt','wt');
		        fid_y = fopen('.\Result\out_y_hat_SNR15_P5_result.txt','wt');
            case 6
                indata = textread('.\packet_6\input_H_and_y.dat','%s');
                fid_R = fopen('.\Result\out_R_SNR15_P6_result.txt','wt');
		        fid_y = fopen('.\Result\out_y_hat_SNR15_P6_result.txt','wt');
            case 7
                indata = textread('.\Extra_Pattern\SNR10\E1\input_H_and_y.dat','%s');
                fid_R = fopen('.\Result\Extra_Pattern\out_R_SNR10_E1_result.txt','wt');
                fid_y = fopen('.\Result\Extra_Pattern\out_y_hat_SNR10_E1_result.txt','wt');
            case 8
                indata = textread('.\Extra_Pattern\SNR10\E2\input_H_and_y.dat','%s');
                fid_R = fopen('.\Result\Extra_Pattern\out_R_SNR10_E2_result.txt','wt');
                fid_y = fopen('.\Result\Extra_Pattern\out_y_hat_SNR10_E2_result.txt','wt');
            case 9
                indata = textread('.\Extra_Pattern\SNR10\E3\input_H_and_y.dat','%s');
                fid_R = fopen('.\Result\Extra_Pattern\out_R_SNR10_E3_result.txt','wt');
                fid_y = fopen('.\Result\Extra_Pattern\out_y_hat_SNR10_E3_result.txt','wt');
            case 10
                indata = textread('.\Extra_Pattern\SNR10\E4\input_H_and_y.dat','%s');
                fid_R = fopen('.\Result\Extra_Pattern\out_R_SNR10_E4_result.txt','wt');
                fid_y = fopen('.\Result\Extra_Pattern\out_y_hat_SNR10_E4_result.txt','wt');
            case 11
                indata = textread('.\Extra_Pattern\SNR10\E5\input_H_and_y.dat','%s');
                fid_R = fopen('.\Result\Extra_Pattern\out_R_SNR10_E5_result.txt','wt');
                fid_y = fopen('.\Result\Extra_Pattern\out_y_hat_SNR10_E5_result.txt','wt');
            case 12
                indata = textread('.\Extra_Pattern\SNR10\E6\input_H_and_y.dat','%s');
                fid_R = fopen('.\Result\Extra_Pattern\out_R_SNR10_E6_result.txt','wt');
                fid_y = fopen('.\Result\Extra_Pattern\out_y_hat_SNR10_E6_result.txt','wt');
            case 13
                indata = textread('.\Extra_Pattern\SNR10\E7\input_H_and_y.dat','%s');
                fid_R = fopen('.\Result\Extra_Pattern\out_R_SNR10_E7_result.txt','wt');
                fid_y = fopen('.\Result\Extra_Pattern\out_y_hat_SNR10_E7_result.txt','wt');
            case 14
                indata = textread('.\Extra_Pattern\SNR10\E8\input_H_and_y.dat','%s');
                fid_R = fopen('.\Result\Extra_Pattern\out_R_SNR10_E8_result.txt','wt');
                fid_y = fopen('.\Result\Extra_Pattern\out_y_hat_SNR10_E8_result.txt','wt');
            case 15
                indata = textread('.\Extra_Pattern\SNR10\E9\input_H_and_y.dat','%s');
                fid_R = fopen('.\Result\Extra_Pattern\out_R_SNR10_E9_result.txt','wt');
                fid_y = fopen('.\Result\Extra_Pattern\out_y_hat_SNR10_E9_result.txt','wt');
            case 16
                indata = textread('.\Extra_Pattern\SNR10\E10\input_H_and_y.dat','%s');
                fid_R = fopen('.\Result\Extra_Pattern\out_R_SNR10_E10_result.txt','wt');
                fid_y = fopen('.\Result\Extra_Pattern\out_y_hat_SNR10_E10_result.txt','wt');
            case 17
                indata = textread('.\Extra_Pattern\SNR15\E1\input_H_and_y.dat','%s');
                fid_R = fopen('.\Result\Extra_Pattern\out_R_SNR15_E1_result.txt','wt');
                fid_y = fopen('.\Result\Extra_Pattern\out_y_hat_SNR15_E1_result.txt','wt');
            case 18
                indata = textread('.\Extra_Pattern\SNR15\E2\input_H_and_y.dat','%s');
                fid_R = fopen('.\Result\Extra_Pattern\out_R_SNR15_E2_result.txt','wt');
                fid_y = fopen('.\Result\Extra_Pattern\out_y_hat_SNR15_E2_result.txt','wt');
            case 19
                indata = textread('.\Extra_Pattern\SNR15\E3\input_H_and_y.dat','%s');
                fid_R = fopen('.\Result\Extra_Pattern\out_R_SNR15_E3_result.txt','wt');
                fid_y = fopen('.\Result\Extra_Pattern\out_y_hat_SNR15_E3_result.txt','wt');
            case 20
                indata = textread('.\Extra_Pattern\SNR15\E4\input_H_and_y.dat','%s');
                fid_R = fopen('.\Result\Extra_Pattern\out_R_SNR15_E4_result.txt','wt');
                fid_y = fopen('.\Result\Extra_Pattern\out_y_hat_SNR15_E4_result.txt','wt');
            case 21
                indata = textread('.\Extra_Pattern\SNR15\E5\input_H_and_y.dat','%s');
                fid_R = fopen('.\Result\Extra_Pattern\out_R_SNR15_E5_result.txt','wt');
                fid_y = fopen('.\Result\Extra_Pattern\out_y_hat_SNR15_E5_result.txt','wt');
            case 22
                indata = textread('.\Extra_Pattern\SNR15\E6\input_H_and_y.dat','%s');
                fid_R = fopen('.\Result\Extra_Pattern\out_R_SNR15_E6_result.txt','wt');
                fid_y = fopen('.\Result\Extra_Pattern\out_y_hat_SNR15_E6_result.txt','wt');
            case 23
                indata = textread('.\Extra_Pattern\SNR15\E7\input_H_and_y.dat','%s');
                fid_R = fopen('.\Result\Extra_Pattern\out_R_SNR15_E7_result.txt','wt');
                fid_y = fopen('.\Result\Extra_Pattern\out_y_hat_SNR15_E7_result.txt','wt');
            case 24
                indata = textread('.\Extra_Pattern\SNR15\E8\input_H_and_y.dat','%s');
                fid_R = fopen('.\Result\Extra_Pattern\out_R_SNR15_E8_result.txt','wt');
                fid_y = fopen('.\Result\Extra_Pattern\out_y_hat_SNR15_E8_result.txt','wt');
            case 25
                indata = textread('.\Extra_Pattern\SNR15\E9\input_H_and_y.dat','%s');
                fid_R = fopen('.\Result\Extra_Pattern\out_R_SNR15_E9_result.txt','wt');
                fid_y = fopen('.\Result\Extra_Pattern\out_y_hat_SNR15_E9_result.txt','wt');
            case 26
                indata = textread('.\Extra_Pattern\SNR15\E10\input_H_and_y.dat','%s');
                fid_R = fopen('.\Result\Extra_Pattern\out_R_SNR15_E10_result.txt','wt');
                fid_y = fopen('.\Result\Extra_Pattern\out_y_hat_SNR15_E10_result.txt','wt');
            otherwise
                indata = textread('.\Extra_Pattern\SNR10\E1\input_H_and_y.dat','%s');
                fid_R = fopen('.\Result\Extra_Pattern\out_R_SNR10_E1_result.txt','wt');
                fid_y = fopen('.\Result\Extra_Pattern\out_y_hat_SNR10_E1_result.txt','wt');
    end

end