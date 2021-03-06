# Copyright (C) 2006-2009, Parrot Foundation.
# $Id$

=head1 WMLScript bytecode to Parrot PBC Translator

=head2 Synopsis

 parrot wmls2pbc.pir file.wmlsc

=head2 Description

B<wmls2pbc> translates a WMLScript bytecode file to Parrot PBC.

=head2 See Also

wmlsd, wmls2pir, wmlsi

=cut

.HLL 'wmlscript'

.sub 'main' :main
    .param pmc argv
    load_language 'wmlscript'
    .local int argc
    .local string progname
    .local string filename
    .local string content
    argc = elements argv
    if argc != 2 goto USAGE
    progname = shift argv
    filename = shift argv
    content = load_script(filename)
    unless content goto L1
    .local pmc loader
    .local pmc script
    new loader, 'WmlsBytecode'
    push_eh _handler
    script = loader.'load'(content)
    script['filename'] = filename
    .local string gen_pir
    gen_pir = script.'translate'()
    .local pmc pir_comp
    .local pmc pbc_out
    pir_comp = compreg 'PIR'
    pbc_out = pir_comp(gen_pir)
    save_pbc(pbc_out, filename)
    pop_eh
  L1:
    end
  USAGE:
    .local pmc stderr
    stderr = getstderr
    print stderr, "Usage: parrot wmls2pbc.pir filename\n"
    exit -1
  _handler:
    .local pmc e
    .local string msg
    .get_results (e)
    msg = e
    say msg
    end
.end


# Local Variables:
#   mode: pir
#   fill-column: 100
# End:
# vim: expandtab shiftwidth=4 ft=pir:
