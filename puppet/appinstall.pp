##TODO: Fix homebrew setup
include homebrew

# class {'homebrew':
#   user  => temikus,
#   group => admin,
# }

package { 'wget': provider => brew }
package { 'autojump': provider => brew }
package { 'mtr': provider => brew }


package { 'adium': provider => 'brewcask' }