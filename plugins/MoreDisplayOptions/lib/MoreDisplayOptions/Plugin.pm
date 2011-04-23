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
    my $show_title;
    my $show_text;
    if (! $entry_prefs ) {
        $show_title = 1;
        $show_text = 1;
    } else {
        my @prefs = split( /,/, $entry_prefs );
        $show_title = 1 if grep( /^title$/, @prefs );
        $show_text = 1 if grep( /^text$/, @prefs );
    }
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
    $$tmpl =~ s/disabled="disabled"//g;
    my $prefs = 'entry_prefs';
    my $object_type = 'entry';
    if ( $app->param( '_type' ) eq 'page' ) {
        $prefs = 'page_prefs';
        $object_type = 'page';
    }
    my $show_title;
    my $show_text;
    my $entry_prefs = $app->permissions->$prefs;
    if (! $entry_prefs ) {
        $show_title = 1;
        $show_text = 1;
    } else {
        my @prefs = split( /,/, $entry_prefs );
        $show_title = 1 if grep( /^title$/, @prefs );
        $show_text = 1 if grep( /^text$/, @prefs );
    }
    my $search = quotemeta( '<mt:setvarblock name="html_head" append="1">' );
    my $css = '';
    if (! $show_title ) {
        $css .= '<style type="text/css">#title-field{display:none;}</style>';
    }
    if (! $show_text ) {
        $css .= '<style type="text/css">#text-field{display:none;}</style>';
    }
    $$tmpl =~ s/($search)/$1$css/;
    if ( MT->version_id =~ /^5\.0/ ) {
        my $head = <<'HEAD';
    <script type="text/javascript">
        function setTitleField(cb) {
            if (cb.checked) {
                jQuery('#title-field').css('display','block');
            } else {
                jQuery('#title-field').css('display','none');
            }
        }
        function setTextField( cb ) {
            if (cb.checked) {
                jQuery('#text-field').css('display','block');
            } else {
                jQuery('#text-field').css('display','none');
            }
        }
    </script>
HEAD
        $$tmpl =~ s/($search)/$1$head/;
    } else {
        my $iliad = quotemeta( "var data = [ 'title', 'text' ];" );
        my $iliad_new = <<'HEAD';
          var data = [];
          if (jQuery('#title-field').css('display') != 'none') {
              data.push('title');
          }
          if (jQuery('#text-field').css('display') != 'none') {
              data.push('text');
          }
HEAD
        $$tmpl =~ s/$iliad/$iliad_new/;
    }
    return 1;
}

sub prefs_option_output {
    my ( $cb, $app, $tmpl ) = @_;
    if ( MT->version_id =~ /^5\.0/ ) {
        my $search = quotemeta( '<input type="checkbox" name="custom_prefs" id="custom-prefs-title" value="title" onclick="setCustomFields();' );
        my $replace = '<input type="checkbox" name="custom_prefs" id="custom-prefs-title" value="title" onclick="setTitleField(this);"';
        $$tmpl =~ s/$search/$replace/g;
        $search = quotemeta( '<input type="checkbox" name="custom_prefs" id="custom-prefs-text" value="text" onclick="setCustomFields();' );
        $replace = '<input type="checkbox" name="custom_prefs" id="custom-prefs-text" value="text" onclick="setTextField(this);"';
        $$tmpl =~ s/$search/$replace/g;
    }
    return 1;
}

1;