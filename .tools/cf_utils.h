#ifndef CF_UTILS_INCLUDED
#define CF_UTILS_INCLUDED

#include <vector>
#include <algorithm>
#include <iostream>

typedef unsigned address_type;

#define TAKEN true
#define NOT_TAKEN false
#define INVALID_THREAD_ACTIVE_STATUS 0
#define WARP_SIZE 32
#define FNAME_SIZE 1024

//SOHUM: The definitions used for branch types
#define BRANCH_INTRN 0
#define BRANCH_EXTRN 1

enum thread_active_status{
	ACTIVE,
	INACTIVE_EXTRINSIC,
	INACTIVE_INTRINSIC
};

class tagged_branch_target_buffer_entry
{
public:

	// Constructor for the class
	tagged_branch_target_buffer_entry(bool _tag, address_type _src,
	address_type _targ);	
	tagged_branch_target_buffer_entry(address_type _src, address_type _targ);
	tagged_branch_target_buffer_entry(
		address_type _src,
		address_type _targ,
		bool _tag,
		unsigned int _instances,
		float _taken_fraction,
		float _occupancy,
		int _dyn_count);
	// Destructor for the class
	~tagged_branch_target_buffer_entry();

	// Defining operators (equality or others, as and when required)
	bool operator==(tagged_branch_target_buffer_entry const& btb_entry) const;

	// Reading the current state of the BTB entry
	bool getTag() {return tag;}
	address_type get_source() const{return source;}
	address_type get_target() const{return target;}
	int get_taken_count() const{return taken_count;}
	int get_instances() const{return instances;}
	float get_taken_fraction() const;
	float get_occupancy() const;
	int get_dyn_inst_count() const;

	// Modifying the current state of the BTB entry
	void update_branch(bool& direction);
	void merge(tagged_branch_target_buffer_entry const* _entry);
					// Add the instances, taken count etc
					// of another BTB entry to this entry
	void print();
private:
	bool tag;			// Indicates whether the branch is
					// intrinsic or extrinsic
	address_type source;
	address_type target;
	unsigned int instances;
	unsigned int taken_count;
	std::vector<float> occupancy;
	std::vector<int> dyn_inst_count;
};

struct match_btb_entry{
	address_type source;
	address_type target;
	match_btb_entry(const address_type& _src, const address_type& _targ) : source(_src), target(_targ) {}
	bool operator()(tagged_branch_target_buffer_entry* const& btb_entry) const;
};

class tagged_branch_target_buffer
{
private:
	std::vector<tagged_branch_target_buffer_entry*> btb;	

public:
	tagged_branch_target_buffer();
	void print_intrinsic_extrinsic_stats();
	void add_btb_entry(tagged_branch_target_buffer_entry* _entry);
	void print();
	void flush();
};
#endif // end #ifndef CF_UTILS_INCLUDED
