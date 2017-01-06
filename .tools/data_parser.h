#ifndef __DATA_PARSER_H_INCLUDED
#define __DATA_PARSER_H_INCLUDED

#include "cf_utils.h"
#include <map>
#include <vector>
#include <string>
#include <sstream>

class btb_data_parser
{
public:
	btb_data_parser();
	void print_gnuplot_file(char* output_filename);	
	void parse_btb_line(std::string &line);
	void parse_kernel_line(std::string &line);
	void print_btb() { m_btb.print(); }
	void print_intrinsic_extrinsic_stats();
private:
	std::map<int, std::string> m_kernel_name;
	tagged_branch_target_buffer m_btb;
};

#endif

