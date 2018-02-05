"""Download data from Elanthipedia"""

import urllib.request
import urllib.parse
import json
import yaml
from re import sub
import argparse
from pathlib import Path


EPEDIA_API = 'https://elanthipedia.play.net/api.php'
# Assumes script is in util or some subdir of dr-scripts folder
DATA_PATH = Path(__file__).resolve().parents[1] / 'data'


class EpediaDownloader:
    def __init__(self):
        parser = argparse.ArgumentParser(description='Download data from Elanthipedia')
        parser.add_argument('command', choices=['titles'], help='What to download')
        args = parser.parse_args()

        # Use dispatch pattern
        if not hasattr(args, 'command'):
            parser.error("Invalid command")
            exit(1)

        getattr(self, args.command)()

    def fetch(self, _values):
        data = urllib.parse.urlencode(_values).encode('ascii')
        req = urllib.request.Request(EPEDIA_API, data)

        with urllib.request.urlopen(req) as response:
            return json.loads(response.read().decode('utf-8'))

    def titles(self):
        """Download and clean a list of all the titles. Then save to data directory"""
        values = {
            'action': 'query',
            'list': 'categorymembers',
            'cmtitle': 'Category:Titles',
            'format': 'json',
            'cmlimit': 500, # There are currently ~3700 titles, but only 500 are returned
        }

        titles = []
        for x in range(10):
            result = self.fetch(values)
            titles += [item['title'] for item in result['query']['categorymembers']]
            if 'continue' in result:
                values['cmcontinue'] = result['continue']['cmcontinue']
            else:
                break

        # Remove guild annotations, e.g. 'Archivist (Moon Mage)' and 'Archivist (Trader)'
        titles = [sub(r'\(.*\)', '', item).strip() for item in titles]

        # Remove non titles
        titles = [title[6:] for title in titles if 'Title:' in title[:6]]

        # Dedupe
        titles = list(set(titles))

        titles.sort()
        # Write to file
        data_dict = {'titles': titles}
        data_file = DATA_PATH / 'base-titles.yaml'
        with data_file.open(mode='w') as outfile:
            yaml.dump(data_dict, outfile, default_flow_style=False)

        print("Saved {num} titles to {data_file}".format(data_file=data_file, num=len(titles)))

if __name__ == '__main__':
    EpediaDownloader()

