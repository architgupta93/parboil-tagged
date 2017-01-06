#include "cf_utils.h"
#include <string>
#include <stdio.h>
#include <fstream>
#include <sstream>
#include <boost/lexical_cast.hpp>

// Declaring functions for a BTB entry

tagged_branch_target_buffer_entry::tagged_branch_target_buffer_entry(bool _tag,
address_type _src, address_type _targ)
{
	tag = _tag;
	source = _src;	
	target = _targ;
	instances = 0;
	taken_count = 0;
	occupancy = std::vector<float> ();
}

tagged_branch_target_buffer_entry::tagged_branch_target_buffer_entry(
	address_type _src,
	address_type _targ,
	bool _tag,
	unsigned int _instances,
	float _taken_fraction,
	float _occupancy,
	int _dyn_count)
{
	tag = _tag;
	source = _src;
	target = _targ;
	occupancy = std::vector<float> ();
	dyn_inst_count = std::vector<int> ();
	instances = _instances;
	taken_count = (unsigned int) (_taken_fraction * (float) _instances);
	occupancy.push_back(_occupancy);
	dyn_inst_count.push_back(_dyn_count);
}

tagged_branch_target_buffer_entry::tagged_branch_target_buffer_entry(
address_type _src, address_type _targ)
{
	source = _src;	
	target = _targ;
	instances = 0;
	taken_count = 0;
	occupancy = std::vector<float> ();
	dyn_inst_count = std::vector<int> ();
}

bool tagged_branch_target_buffer_entry::operator==(tagged_branch_target_buffer_entry 
const& btb_entry) const
{
	return (source==btb_entry.get_source() && target==btb_entry.get_target());
};

int tagged_branch_target_buffer_entry::get_dyn_inst_count() const
{
	float count = 0;
	std::vector<int>::const_iterator it;	
	for (it=dyn_inst_count.begin(); it != dyn_inst_count.end(); it++)
	{
		count += (*it);
	}
	return count;
}

float tagged_branch_target_buffer_entry::get_occupancy() const
{
	float occupied = 0;
	float total_count = 0.0;
	std::vector<float>::const_iterator it;
	std::vector<int>::const_iterator dt;
	dt = dyn_inst_count.begin();
	for (it=occupancy.begin(); it!=occupancy.end() && dt!=dyn_inst_count.end(); )
	{
		occupied += (*it) * ((float) (*dt));
		total_count += (float) (*dt);
		it++; dt++;	
	}
	if(total_count<=0.0)
	{
		std::cout << "ERROR: Count < 0, Vector size " << dyn_inst_count.size() << "\n";
		assert(total_count>0.0);
	}
	return occupied/total_count;
}

float tagged_branch_target_buffer_entry::get_taken_fraction() const
{
	return (((float) taken_count)/((float) instances));
}

void tagged_branch_target_buffer_entry::update_branch(bool& direction)
{
	instances++;
	if(direction) taken_count++;
}

void tagged_branch_target_buffer_entry::merge(const tagged_branch_target_buffer_entry* _entry)
{
	instances += _entry->get_instances();
	taken_count += _entry->get_taken_count();
	occupancy.push_back(_entry->get_occupancy());
	dyn_inst_count.push_back(_entry->get_dyn_inst_count());
}

void tagged_branch_target_buffer_entry::print()
{
	const char* int_desc = "intrinsic";
	const char* ext_desc = "extrinsic";
	if (tag==BRANCH_INTRN)
		printf("%12x %12s %12x %10u %12f %15f %12d\n", source, int_desc, target, instances, get_taken_fraction(), get_occupancy(), get_dyn_inst_count());
	else				
		printf("%12x %12s %12x %10u %12f %15f %12d\n", source, ext_desc, target, instances, get_taken_fraction(), get_occupancy(), get_dyn_inst_count());
}

// Function declarations for a BTB

void tagged_branch_target_buffer::print_intrinsic_extrinsic_stats()
{
	tagged_branch_target_buffer_entry* intrinsic = new tagged_branch_target_buffer_entry(BRANCH_INTRN, (address_type) 0000, (address_type) 0x1234) ;
	tagged_branch_target_buffer_entry* extrinsic = new tagged_branch_target_buffer_entry(BRANCH_EXTRN, (address_type) 0000, (address_type) 0xabcd);

	bool atleast_1_intrinsic = false;
	bool atleast_1_extrinsic = false;
	std::vector<tagged_branch_target_buffer_entry*>::const_iterator it;

	for (it = btb.begin(); it != btb.end(); it++)
	{
		if ((*it)->getTag()==BRANCH_EXTRN)
		{
			atleast_1_extrinsic = true;
			extrinsic->merge(*it);
		}
		else if ((*it)->getTag()==BRANCH_INTRN)
		{
			atleast_1_intrinsic = true;
			intrinsic->merge(*it);
		}	
	}
	tagged_branch_target_buffer int_ext_btb;
	if (atleast_1_intrinsic) int_ext_btb.add_btb_entry(intrinsic);
	if (atleast_1_extrinsic) int_ext_btb.add_btb_entry(extrinsic);
	int_ext_btb.print();
}

bool match_btb_entry::operator()(tagged_branch_target_buffer_entry* const&
btb_entry) const
{
	return (btb_entry->get_source()==source && btb_entry->get_target()==target);
}

tagged_branch_target_buffer::tagged_branch_target_buffer()
{
	btb = *(new std::vector<tagged_branch_target_buffer_entry*> ());
}

void tagged_branch_target_buffer::add_btb_entry(tagged_branch_target_buffer_entry* _entry)
{
	address_type _src=_entry->get_source();
	address_type _targ=_entry->get_target();
	std::vector<tagged_branch_target_buffer_entry*>:: iterator it;
	it = std::find_if(btb.begin(), btb.end(), match_btb_entry(_src,_targ));
	if(it != btb.end()) 
	{
		(*it)->merge(_entry);
	}
	else
	{
		btb.push_back(_entry);	
	}
}

void tagged_branch_target_buffer::print()
{
	printf("------------------------------------------------------------------------------------------------\n");
	printf("%12s %12s %12s %10s %12s %15s %12s\n", "PC", "TYPE", "TARGET", "INSTANCES", "TAKEN", "OCCUPANCY", "DYN_COUNT");
	printf("------------------------------------------------------------------------------------------------\n");
	std::vector<tagged_branch_target_buffer_entry*>:: iterator it;
	for (it=btb.begin(); it != btb.end(); it++)
	{
		(*it)->print();
	}
	return;
}

void tagged_branch_target_buffer::flush()
{
	btb.clear();	
}
