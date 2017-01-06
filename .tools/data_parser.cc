/* 	C file for reading and manipulating data from different run logs
 *  	Author: Archit Gupta (Nov 21, 2015)
 */  	

#include <stdio.h>
#include "data_parser.h"
#include <boost/lexical_cast.hpp>

btb_data_parser::btb_data_parser()
{

}

void btb_data_parser::print_gnuplot_file(char* output_filename)
{

}

void btb_data_parser::print_intrinsic_extrinsic_stats()
{
	m_btb.print_intrinsic_extrinsic_stats();
}

void btb_data_parser::parse_btb_line(std::string &line)
{
	std::stringstream m_line_stream;
	address_type _src, _targ;
	bool _tag;
	int _instances;
	int _dyn_count;
	float _taken_fraction, _occupancy;
	std::string word_in_line;
	m_line_stream.str(line);
	//std::cout << "Confirm :" << line << "\n";
	try{
		m_line_stream >> std::hex >> _src;
		m_line_stream >> word_in_line;
		_tag = (word_in_line == "extrinsic");
		m_line_stream >> std::hex >> _targ;
		m_line_stream >> word_in_line;
		_instances = boost::lexical_cast<unsigned int>(word_in_line);
		//std::cout << "Read the value " << word_in_line <<  ", parsed " << _instances <<"\n";
		m_line_stream >> _taken_fraction;
		m_line_stream >> _occupancy;
		m_line_stream >> word_in_line;
		_dyn_count = boost::lexical_cast<int>(word_in_line);
		tagged_branch_target_buffer_entry* _tmp = new tagged_branch_target_buffer_entry(
			_src,
			_targ,
			_tag,
			_instances,
			_taken_fraction,
			_occupancy,
			_dyn_count
		);
		m_btb.add_btb_entry(_tmp);
	}
	catch (std::exception& ex) 
	{
		std::cout << ex.what();
	}
}

void btb_data_parser::parse_kernel_line(std::string& line)
{

}
