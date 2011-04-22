package MoreDisplayOptions::Plugin;

use strict;

sub prefs_option_param {
    my ( $cb, $app, $param, $tmpl ) = @_;
    my $prefs = 'entry_prefs';
    my $object_type = 'entry';
    if ( $param->{ object_type } eq 'page' ) {
        $prefs = 'page_prefs';
        $object_type = 'page';
    }
    my $entry_prefs = $app->permissions->$prefs;
    my @prefs = split( /,/, $entry_prefs );
    my $show_title = 1 if grep( /^title$/, @prefs );
    my $show_text = 1 if grep( /^text$/, @prefs );
    my $field_loop = $param->{ field_loop };
    my @new_loop;
    for my $field ( @$field_loop ) {
        if ( $field->{ field_id } eq 'title' ) {
            $field->{ show_field } = $show_title;
        }
        if ( $field->{ field_id } eq 'text' ) {
            $field->{ show_field } = $show_text;
        }
        push ( @new_loop, $field );
    }
    $param->{ field_loop } = \@new_loop;
    return 1;
}

sub prefs_option_source {
    my ( $cb, $app, $tmpl ) = @_;
    my $prefs = 'entry_prefs';
    my $object_type = 'entry';
    if ( $app->param( '_type' ) eq 'page' ) {
        $prefs = 'page_prefs';
        $object_type = 'page';
    }
    my $entry_prefs = $app->permissions->$prefs;
    my @prefs = split( /,/, $entry_prefs );
    my $show_title = 1 if grep( /^title$/, @prefs );
    my $show_text = 1 if grep( /^text$/, @prefs );
    $$tmpl =~ s/disabled="disabled"//g;
    my $search = quotemeta( '<mt:setvarblock name="html_head" append="1">' );
    my $head = <<'HEAD';
    <script type="text/javascript">
        function setTitleField( cb ) {
            if ( cb.checked ) {
                getByID( 'title-field' ).style.display='block';
            } else {
                getByID( 'title-field' ).style.display='none';
            }
        }
        function setTextField( cb ) {
            if ( cb.checked ) {
                getByID( 'text-field' ).style.display='block';
            } else {
                getByID( 'text-field' ).style.display='none';
            }
        }
    </script>
HEAD
    if (! $show_title ) {
        $head .= <<'HEAD';
        <style type="text/css">
            #title-field { display:none; }
        </style>
HEAD
    }
    if (! $show_text ) {
        $head .= <<'HEAD';
        <style type="text/css">
            #text-field { display:none; }
        </style>
HEAD
    }
    $$tmpl =~ s/($search)/$1$head/;
    return 1;
}

sub prefs_option_output {
    my ( $cb, $app, $tmpl ) = @_;
    my $search = quotemeta( '<input type="checkbox" name="custom_prefs" id="custom-prefs-title" value="title" onclick="setCustomFields();' );
    my $replace = '<input type="checkbox" name="custom_prefs" id="custom-prefs-title" value="title" onclick="setTitleField(this);"';
    $$tmpl =~ s/$search/$replace/g;
    $search = quotemeta( '<input type="checkbox" name="custom_prefs" id="custom-prefs-text" value="text" onclick="setCustomFields();' );
    $replace = '<input type="checkbox" name="custom_prefs" id="custom-prefs-text" value="text" onclick="setTextField(this);"';
    $$tmpl =~ s/$search/$replace/g;
    return 1;
}

1;