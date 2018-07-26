from lxml import html
from lxml import etree
import sys
import re

def as_trimmed_text(node):
    res = ""
    for t in node.xpath(".//text()"):
        res += t.strip()
    return res


dialogs = []
fns = sys.argv[1:]

for fn in fns:
    fh = open(fn)
    xp = html.fromstring(fh.read())
    fh.close()

    dialog = dict()

    title = None

    if xp.xpath('//div[@class="head2"]/p'):
        title = xp.xpath('//div[@class="head2"]/p')[0].text_content()
    elif xp.xpath('//p[@class="head2"]'):
        title = xp.xpath('//p[@class="head2"]')[0].text_content()
    elif xp.xpath('//div[@class="head1"]/p'):
        title = xp.xpath('//div[@class="head1"]/p')[0].text_content()
    elif xp.xpath('//p[@class="head1"]'):
        title = xp.xpath('//p[@class="head1"]')[0].text_content()
    elif xp.xpath('//div[@class="head1"]'):
        title = xp.xpath('//div[@class="head1"]')[0].text_content()
    elif xp.xpath('//div[@class="head2"]'):
        title = xp.xpath('//div[@class="head2"]')[0].text_content()

    if title is None:
        sys.stderr.print("No title found in ", fn)

    print(title)

    # remove all <span class="dir">....</span> from doc
    stage_directions = xp.xpath('//p/span[@class="dir"]') + xp.xpath('//span[@class="dir"]') 
    print(stage_directions)
    for sd in stage_directions:
        if sd.getparent() is not None:
            sd.drop_tree()
    

    parsed_lines = []
    
    # all p's that contain a <span class="dpart">
    # that works for every show EXCEPT princess ida
    lines = xp.xpath('//p[./span[@class="dpart"]]')
    if lines:
        for line in lines:
	    # get the part name
            part_name = line.findall('span[@class="dpart"]')[0].text_content()

	    # clean up part name
            part_name = re.sub(r'^\s+', '', part_name)
            part_name = re.sub(r'\s+$', '', part_name)
            part_name = re.sub(r'\.', '', part_name)
	
	    # remove the part name from the line
            for occ in (line.findall('span[@class="dpart"]')):
                occ.drop_tree()

            line_obj = { 'part': part_name, 'line': as_trimmed_text(line) }
            parsed_lines.append(line_obj)
    else:
        part_rows = xp.xpath('//tr[./td[@class="part"]]')
        previous_part = None
        previous_lines = []
        for row in part_rows:
            part_name = row.findall('td[@class="part"]')[0].text_content()
            if (not re.search(r'\w', part_name)):
                # continuation of the previous line, yay! omg
                part_name = previous_part;
		
            part_name = re.sub(r'\./', '', part_name)
            line = " ".join([ as_trimmed_text(n) for n in row.findall('td[@class=tlyric"]') if re.search(r'\w', n) ])
	    #my $line = join " ", grep { /\w/ } map { $_->as_trimmed_text } $row->findnodes('td[@class="tlyric"]');
	    
            if (not previous_part or part_name != previous_part):
                if previous_lines:
                    previous_line_obj = { 'part': previous_part, 'line': " ".join(previous_lines) }
                    parsed_lines.append(previous_line_obj)

                previous_lines = []
	    

            previous_part = part_name
            previous_lines.append(line)
	
        if (previous_lines):
            previous_line_obj = { 'part': previous_part, 'line': " ".join(previous_lines) }
            parsed_lines.append(previous_line_obj)

    dialog['lines'] = parsed_lines
    dialogs.append(dialog)
    
#    print Dumper(\@lines);

print(dialogs)
'''
#print Dumper(\@dialogs);
print encode_json(\@dialogs);
    
'''

