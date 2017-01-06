/* 	C file for reading and manipulating data from different run logs
 *  	Author: Archit Gupta (Nov 21, 2015)
 */  	

#include <stdio.h>
#include <iostream>
#include <fstream>
#include "data_parser.h"

char* invalid_io(std::string help_message)
{
	char* filename;
	printf("%s: ", help_message);
	scanf(filename);
	return filename;
}

int main(int argc, char** argv)
{
	const std::string btb_data_help_message = "BTB data file: ";
	const std::string kernel_name_help_message = "Kernel names file: ";
	char *f_btb_data, *f_kernel_names;
	std::ifstream s_btb_stream, s_kernel_stream;
	btb_data_parser m_btb_data_parser;
	std::string line_in_file; 

	// Checking if the input command is valid (has the required filenames)
	if (argc < 3)
	{
		printf("Please supply the input text file(s)!\n");
		f_btb_data = invalid_io(btb_data_help_message);
		f_kernel_names = invalid_io(kernel_name_help_message);
	} 
	else
	{
		f_btb_data = argv[1];
		f_kernel_names =  argv[2];
	}

	// Open the file containing BTB data
	
	s_btb_stream.open(f_btb_data, std::ios::in);
	try {
	 	std::getline(s_btb_stream, line_in_file);
	} 
	catch (std::exception)
	{
		printf("Error reading file: %s.\n", f_btb_data);
		printf("Is the file empty?");
	}	

	while (!s_btb_stream.eof())
	{
		if (line_in_file != "")
		{
			//std::cout << "Parsing :" << line_in_file << "\n";
			m_btb_data_parser.parse_btb_line(line_in_file);	
		}
	 	std::getline(s_btb_stream, line_in_file);
	}
	s_btb_stream.close();

	// Open the file containing Kernel names
	s_kernel_stream.open(f_kernel_names, std::ios::in);
	try {
	 	std::getline(s_kernel_stream, line_in_file);
	} 
	catch (std::exception) 
	{
		printf("Error reading file: %s.\n", f_kernel_names);
		printf("Is the file empty?");
	}	

	while (!s_btb_stream.eof())
	{
		if (line_in_file != "")
		{
			m_btb_data_parser.parse_kernel_line(line_in_file);	
		}
	 	std::getline(s_kernel_stream, line_in_file);
	}
	
	s_btb_stream.close();
	m_btb_data_parser.print_btb();	
	m_btb_data_parser.print_intrinsic_extrinsic_stats();	
}
