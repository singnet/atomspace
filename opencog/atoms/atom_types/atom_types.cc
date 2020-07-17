/**
 * atom_types.cc
 *
 * Generic Atom Types declaration
 *
 * Copyright (c) 2009, 2014 Linas Vepstas <linasvepstas@gmail.com>
 */

// library initialization

static __attribute__ ((constructor)) void init(void)
{
#define str(x) #x
#define xstr(x) str(x)

	bool is_init = opencog::nameserver().beginTypeDecls(xstr(INITNAME));
	if (is_init) return;

	#include INHERITANCE_FILE
	#ifdef INHERITANCE_FILE2
	#include INHERITANCE_FILE2
	#endif
	opencog::nameserver().endTypeDecls();

	// Backwards compat. Argh...
	opencog::TYPE_SET_LINK = opencog::TYPE_INTERSECTION_LINK;
}

static __attribute__ ((destructor)) void fini(void)
{
}

extern "C" {
// Calling this forces this shared-lib to load, thus calling the 
// constructor above, thus causing the atom types to be loaded into
// the atomspace.
void INITNAME(void)
{
	/* No-op */
}
};
