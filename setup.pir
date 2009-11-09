#! /usr/local/bin/parrot
# Copyright (C) 2009, Parrot Foundation.

=head1 NAME

setup.pir - Python distutils style

=head1 DESCRIPTION

No Configure step, no Makefile generated.

=head1 USAGE

    $ parrot setup.pir build
    $ parrot setup.pir test
    $ sudo parrot setup.pir install

=cut

.sub 'main' :main
    .param pmc args
    $S0 = shift args
    load_bytecode 'distutils.pbc'

    .const 'Sub' prebuild = 'prebuild'
    register_step_before('build', prebuild)

    .const 'Sub' clean = 'clean'
    register_step_before('clean', clean)

    # build
    $P0 = new 'Hash'
    $P1 = new 'Hash'
    $P1['wmls_ops'] = 'dynext/ops/wmls.ops'
    $P0['dynops'] = $P1
    $P2 = new 'Hash'
    $P3 = split ' ', 'dynext/pmc/wmlsinteger.pmc dynext/pmc/wmlsfloat.pmc dynext/pmc/wmlsstring.pmc dynext/pmc/wmlsboolean.pmc dynext/pmc/wmlsinvalid.pmc dynext/pmc/wmlsbytecode.pmc'
    $P2['wmls_group'] = $P3
    $P0['dynpmc'] = $P2
    $P4 = new 'Hash'
    $P5 = split "\n", <<'SOURCES'
wmlscript/WMLScript.pir
wmlscript/script.pir
wmlscript/wmlsstdlibs.pir
wmlscript/opcode.pir
wmlscript/stdlibs.pir
SOURCES
    $P4['wmlscript/wmlscript.pbc'] = $P5
    $P4['wmlscript/library/wmlslang.pbc'] = 'wmlscript/library/wmlslang.pir'
    $P4['wmlscript/library/wmlsfloat.pbc'] = 'wmlscript/library/wmlsfloat.pir'
    $P4['wmlscript/library/wmlsstring.pbc'] = 'wmlscript/library/wmlsstring.pir'
    $P4['wmlscript/library/wmlsconsole.pbc'] = 'wmlscript/library/wmlsconsole.pir'
    $P4['wmlsi.pbc'] = 'wmlsi.pir'
    $P4['wmlsd.pbc'] = 'wmlsd.pir'
    $P0['pbc_pir'] = $P4
    $P6 = new 'Hash'
    $P6['parrot-wmlsi'] = 'wmlsi.pbc'
    $P6['parrot-wmlsd'] = 'wmlsd.pbc'
    $P0['exe_pbc'] = $P6
    # test
    $S0 = get_parrot()
    $P0['prove_exec'] = $S0
    $P0['prove_files'] = 't/pmc/*.t'
    # install
    $P7 = split ' ', 'wmlscript/wmlscript.pbc wmlscript/library/wmlslang.pbc wmlscript/library/wmlsfloat.pbc wmlscript/library/wmlsstring.pbc wmlscript/library/wmlsconsole.pbc'
    $P0['inst_lang'] = $P7
    .tailcall setup(args :flat, $P0 :flat :named)
.end

.sub 'prebuild' :anon
    .param pmc kv :slurpy :named
    .local string cmd, srm
    srm = 'Stack'
    $P0 = split ' ', 'wmlscript/translation.rules build/translator.pl build/SRM/Stack.pm build/SRM/Register.pm'
    $I0 = newer('wmlscript/opcode.pir', $P0)
    if $I0 goto L1
    cmd = 'perl build/translator.pl'
    cmd .= ' --output wmlscript/opcode.pir'
    cmd .= ' --srm '
    cmd .= srm
    cmd .= ' wmlscript/translation.rules'
    system(cmd)
  L1:
    $P0 = split ' ', 'wmlscript/wmlslibs.cfg build/stdlibs.pl'
    $I0 = newer('wmlscript/stdlibs.pir', $P0)
    if $I0 goto L2
    cmd = 'perl build/stdlibs.pl'
    cmd .= ' --output wmlscript/stdlibs.pir'
    cmd .= ' wmlscript/wmlslibs.cfg'
    system(cmd)
  L2:
.end

.sub 'clean' :anon
    .param pmc kv :slurpy :named
    unlink('wmlscript/opcode.pir')
    unlink('wmlscript/stdlibs.pir')
.end


# Local Variables:
#   mode: pir
#   fill-column: 100
# End:
# vim: expandtab shiftwidth=4 ft=pir:
